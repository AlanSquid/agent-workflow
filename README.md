# agent-workflow

OpenSpec × [Matt Pocock skills](https://github.com/mattpocock/skills) 的混合開發工作流，給 Claude Code、Codex、pi 等 coding agent 使用。

- **OpenSpec** 當文件骨架：proposal、delta specs、tasks，archive 後累積成 living spec（長期的「做什麼」）
- **Matt Pocock skills** 當紀律層：grilling 對齊、垂直切片拆票、TDD、雙軸 code review（「怎麼做」）

## 內容

| Skill | 用途 |
| --- | --- |
| `bootstrap-workflow` | 在新專案一次建好整套工作流：安裝 OpenSpec、Pocock skills，再透過簡短訪談客製化 `openspec/config.yaml` 與 `AGENTS.md` |

Pocock skills 的紀律透過 `openspec/config.yaml` 的 `rules` 接進 `/opsx:propose`，上游 skill 零修改：

- `rules.proposal`：有會改變 specs 或拆法的未決事項時，依 `grilling` 的方式停下來問
- `rules.tasks`：照 `to-tickets` 的切片方法寫 tasks.md（每個 task group 就是一張票，超過一組先確認），但不執行它的發布步驟；每組列出測試接縫，跟切法一起確認

`config.yaml` 只管 artifact 產生階段（proposal / specs / design / tasks），管不到 `/opsx:apply`（`rules.apply` 會被忽略）。`/opsx:apply` 本身也不會 TDD：OpenSpec 只要求「要有測試」，不管先後。所以實作紀律寫在 `AGENTS.md`，它每個 session 都會載入，對 `/opsx:apply` 一樣有效：

- 寫新行為前用 Skill tool 載入 `tdd` skill，照紅綠循環做，只在 tasks.md 列出的接縫寫測試
- 每完成一項：打勾，測試全綠就 commit；commit 標題結尾附上票號「（change: X，第 N 組）」，讓 `/code-review` 能從 commit 找回 spec
- 每完成一個 task group：`/code-review` 審查這組第一個 commit 以來的變更（含其他 repo），修正另外 commit

## 使用

安裝 `bootstrap-workflow`（使用者層級，一次即可）：

```bash
npx skills@latest add AlanSquid/agent-workflow -s bootstrap-workflow -g -a claude-code codex pi -y
```

`/opsx:*` 指令執行的是 PATH 上的 `openspec`，腳本則用 `npx @fission-ai/openspec@latest`。兩者版本要一致（例如 brew 的 1.3.1 不會把 `context` 注入 apply 階段，1.13 會）。

OpenSpec 的全域 profile 決定每個專案會裝哪些 `/opsx:*` 指令，建議用 `core` preset（`openspec config profile core`），它會跟著上游的核心清單走。舊版留下的 `custom` 清單不會自動加入新的核心指令，例如本流程用來重切票的 `/opsx:update`。改完 profile 後，要在各專案跑 `openspec update` 才會生效。

在新專案的根目錄（需為 git repo）執行：

```text
/bootstrap-workflow
```

它會：

1. 執行 `scripts/bootstrap.sh` 裝好固定的部分（可重複執行，不覆蓋既有檔案）
   - `openspec init`
   - Pocock skills：`setup-matt-pocock-skills`、`grilling`、`grill-me`、`grill-with-docs`、`to-tickets`、`implement`、`tdd`、`diagnosing-bugs`、`code-review`、`domain-modeling`、`improve-codebase-architecture`、`codebase-design`、`handoff`（刻意不裝 `to-spec`，spec 由 OpenSpec 負責）
   - 檢查 `to-tickets` 被 `rules.tasks` 引用的段落還在（上游改名時直接報錯）
   - `docs/agents/issue-tracker.md`、`docs/agents/domain.md`
2. 讀專案結構，分輪問你幾個決策問題：專案是什麼、需求文件在哪、誰擁有需求、這個專案的「一片垂直切片」怎麼驗收、會碰到哪些外部 API、常用指令、文件語言
3. 依回答寫入 `openspec/config.yaml` 的 `context` 與 `rules`、`AGENTS.md`（專案段落 + 工作流程章節）、`CLAUDE.md`（`@AGENTS.md`）
4. 驗證並列出建立了什麼；不會自動 commit

## 日常流程（摘要）

| 規模 | 流程 |
| --- | --- |
| 小 | `/opsx:propose` → `/opsx:apply` → `/opsx:archive` |
| 中 | `/grill-with-docs` → `/opsx:propose` → `/opsx:apply` 整份 change → `/opsx:archive` |
| 大 | `/grill-with-docs` → `/opsx:propose`（task group 即票）→ 每張票新 session `/opsx:apply <change> 只做第 N 組` → `/opsx:archive` |

- 實作都用 `/opsx:apply`，依 AGENTS.md 的規則帶進 TDD、每項 commit、每組 code review。`/implement` 可選，效果相同，但要自己交代 change 路徑與打勾
- 需要留下用語與決策紀錄（`CONTEXT.md`、`docs/adr/`）時用 `/grill-with-docs`；只想壓力測試想法、不留文件時用 `/grilling`（`/grill-me` 同義）

完整規則由 `bootstrap-workflow` 寫進各專案的 `AGENTS.md`。

## 更新

```bash
npx skills@latest update      # 更新專案裡的 Pocock skills
npx skills@latest check       # 只檢查有沒有新版

# update 後確認 rules.tasks 引用的 to-tickets 段落都在：應該印出三行（上游改名時 rule 會無聲失效）
grep -E '^#+ .*(Draft vertical slices|Quiz the user|Publish)' .agents/skills/to-tickets/SKILL.md
```

不要手動修改 agent 設定目錄裡產生出來的檔案：Pocock skills 由 `npx skills update` 管理；`openspec-*` skill 與 `/opsx:*` 指令檔（`.agents/skills/`、`.claude/`、`.pi/` 底下都有）由 `openspec update` 管理。兩者更新時都會直接覆蓋。要調整 skill 在本流程裡的行為：規劃階段（propose）改 `openspec/config.yaml` 的 `rules`，實作階段（apply）改 `AGENTS.md` 的規則，skill 找票與 spec 的方式改 `docs/agents/*.md`（上游預留的客製點，`code-review`、`to-tickets` 會讀，不能刪）。

### 範本更新後同步既有專案

`bootstrap.sh` 不覆蓋既有檔案，重跑不會更新已經建好的專案。範本改版後，把 `templates/` 裡這三份檔案的差異手動合併進專案（用 `git log -p -- skills/bootstrap-workflow/templates/` 看改了什麼）：

| 範本 | 專案裡的位置 |
| --- | --- |
| `openspec-config.yaml` 的 `rules` | `openspec/config.yaml`（`context` 與專案自己的 rule 保留） |
| `AGENTS.workflow.md` | `AGENTS.md` 的工作流程章節 |
| `docs/agents/issue-tracker.md`、`domain.md` | `docs/agents/` |

### 從舊版（有 `os-tickets`）遷移

```bash
npx skills@latest remove os-tickets -y
```

再把 `templates/openspec-config.yaml` 的 `rules.proposal` 與 `rules.tasks` 新增的條目、`templates/docs/agents/issue-tracker.md` 與 `templates/AGENTS.workflow.md` 的對應段落合併進專案。

## 目錄結構

```text
skills/
├── bootstrap-workflow/
│   ├── SKILL.md
│   ├── scripts/bootstrap.sh
│   └── templates/
│       ├── AGENTS.workflow.md
│       ├── openspec-config.yaml
│       └── docs/agents/{issue-tracker,domain}.md
```
