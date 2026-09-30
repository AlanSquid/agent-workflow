#!/usr/bin/env bash
# 建立 OpenSpec × Matt Pocock skills 混合工作流的「固定部分」。
#
# 只做每個專案都一樣的事；需要看專案內容才能決定的部分
# （openspec/config.yaml 的 context 與切片定義、AGENTS.md 的專案段落）
# 由 bootstrap-workflow skill 的後續步驟負責。
#
# 可以重複執行：已存在的檔案一律跳過，不覆蓋。
#
# 用法（在專案根目錄）：
#   bash <skill-dir>/scripts/bootstrap.sh
#   bash <skill-dir>/scripts/bootstrap.sh --agents claude-code,codex
set -euo pipefail

AGENTS="claude-code,codex,pi"
SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMPLATES="$SKILL_DIR/templates"

# 刻意不裝 to-spec：spec 由 OpenSpec 負責。
# grill-me / grill-with-docs 只是 grilling 的入口；improve-codebase-architecture 需要 codebase-design。
POCOCK_SKILLS=(
  setup-matt-pocock-skills
  grilling grill-me grill-with-docs
  to-tickets
  implement tdd diagnosing-bugs
  code-review
  domain-modeling
  improve-codebase-architecture codebase-design
  handoff
)

while [[ $# -gt 0 ]]; do
  case "$1" in
    --agents) AGENTS="$2"; shift 2 ;;
    -h|--help) sed -n '2,12p' "$0"; exit 0 ;;
    *) echo "未知參數：$1" >&2; exit 2 ;;
  esac
done

log()  { printf '\n\033[1m==> %s\033[0m\n' "$*"; }
skip() { printf '    跳過：%s\n' "$*"; }
done_() { printf '    完成：%s\n' "$*"; }

# ---- 前置檢查 -------------------------------------------------------------
root="$(git rev-parse --show-toplevel 2>/dev/null || true)"
if [[ -z "$root" ]]; then
  echo "❌ 目前不在 git repo 裡。請先 git init。" >&2
  exit 1
fi
if [[ "$root" != "$(pwd -P)" ]]; then
  echo "❌ 請在 repo 根目錄執行（$root）。" >&2
  exit 1
fi
command -v npx >/dev/null || { echo "❌ 找不到 npx（需要 Node.js）。" >&2; exit 1; }

IFS=',' read -r -a agent_list <<< "$AGENTS"

# skills CLI 與 openspec 對 agent 的代號不同
openspec_tools=()
for a in "${agent_list[@]}"; do
  case "$a" in
    claude-code) openspec_tools+=(claude) ;;
    *) openspec_tools+=("$a") ;;
  esac
done
openspec_tools_csv="$(IFS=','; echo "${openspec_tools[*]}")"

# ---- 1. OpenSpec ----------------------------------------------------------
log "1/4 OpenSpec"
if [[ -f openspec/config.yaml ]]; then
  skip "openspec/ 已存在"
else
  npx -y @fission-ai/openspec@latest init --tools "$openspec_tools_csv" .
  done_ "openspec init（tools: $openspec_tools_csv）"
fi

# ---- 2. Matt Pocock skills ------------------------------------------------
log "2/4 Matt Pocock skills（${#POCOCK_SKILLS[@]} 個）"
npx -y skills@latest add mattpocock/skills -s "${POCOCK_SKILLS[@]}" -a "${agent_list[@]}" -y
done_ "${POCOCK_SKILLS[*]}"

# ---- 3. 檢查 openspec/config.yaml 引用的上游段落 --------------------------
# rules.tasks 以段落標題引用 to-tickets（切片方法、確認、不發布）。上游改名時
# rule 會無聲失效，所以在這裡擋下來。
log "3/4 檢查 to-tickets 段落"
to_tickets=".agents/skills/to-tickets/SKILL.md"
missing=()
for h in "Draft vertical slices" "Quiz the user" "Publish"; do
  grep -qE "^#+ .*$h" "$to_tickets" || missing+=("$h")
done
if (( ${#missing[@]} )); then
  echo "❌ $to_tickets 找不到段落：${missing[*]}" >&2
  echo "   上游 to-tickets 改版了，請更新 templates/openspec-config.yaml 的 rules.tasks 後再執行。" >&2
  exit 1
fi
done_ "to-tickets 段落都在"

# ---- 4. 固定範本 ----------------------------------------------------------
log "4/4 範本檔"
mkdir -p docs/agents docs/adr
for f in issue-tracker.md domain.md; do
  if [[ -f "docs/agents/$f" ]]; then
    skip "docs/agents/$f 已存在"
  else
    cp "$TEMPLATES/docs/agents/$f" "docs/agents/$f"
    done_ "docs/agents/$f"
  fi
done
if [[ -f .gitignore ]] && grep -qxF '.scratch/' .gitignore; then
  skip ".gitignore 已有 .scratch/"
else
  printf '\n# 不屬於任何 change 的臨時工作檔\n.scratch/\n' >> .gitignore
  done_ ".gitignore 加入 .scratch/"
fi

log "固定部分完成"
cat <<EOF
接下來由 bootstrap-workflow skill 處理需要客製化的部分：
  - openspec/config.yaml：context、垂直切片定義、文件語言（範本：$TEMPLATES/openspec-config.yaml）
  - AGENTS.md：專案段落 + 工作流程章節（範本：$TEMPLATES/AGENTS.workflow.md）
  - CLAUDE.md：@AGENTS.md
EOF
