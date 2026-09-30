# agent-workflow

OpenSpec × [Matt Pocock skills](https://github.com/mattpocock/skills) 的混合開發工作流，給 Claude Code、Codex、pi 等 coding agent 使用。

- **OpenSpec** 當文件骨架：proposal、delta specs、tasks，archive 後累積成 living spec（長期的「做什麼」）
- **Matt Pocock skills** 當紀律層：grilling 對齊、垂直切片拆票、TDD、雙軸 code review（「怎麼做」）

## 內容

| Skill | 用途 |
| --- | --- |
| `bootstrap-workflow` | 在新專案一次建好整套工作流：安裝 OpenSpec、Pocock skills、`os-tickets`，再透過簡短訪談客製化 `openspec/config.yaml` 與 `AGENTS.md` |
| `os-tickets` | `to-tickets` 的橋接 skill：照 to-tickets 的方法拆垂直切片，但輸出寫進 `openspec/changes/<change>/tasks.md`。上游 skill 零修改 |

## 使用

安裝 `bootstrap-workflow`（使用者層級，一次即可）：

```bash
npx skills@latest add AlanSquid/agent-workflow -s bootstrap-workflow -g -a claude-code codex pi -y
```

在新專案的根目錄（需為 git repo）執行：

```text
/bootstrap-workflow
```

它會：

1. 執行 `scripts/bootstrap.sh` 裝好固定的部分（可重複執行，不覆蓋既有檔案）
   - `openspec init`
   - Pocock skills：`setup-matt-pocock-skills`、`grilling`、`grill-me`、`grill-with-docs`、`to-tickets`、`implement`、`tdd`、`diagnosing-bugs`、`code-review`、`domain-modeling`、`improve-codebase-architecture`、`codebase-design`、`handoff`（刻意不裝 `to-spec`，spec 由 OpenSpec 負責）
   - 本 repo 的 `os-tickets`
   - `docs/agents/issue-tracker.md`、`docs/agents/domain.md`
2. 讀專案結構，分輪問你幾個決策問題：專案是什麼、需求文件在哪、誰擁有需求、這個專案的「一片垂直切片」怎麼驗收、會碰到哪些外部 API、常用指令、文件語言
3. 依回答寫入 `openspec/config.yaml` 的 `context` 與 `rules`、`AGENTS.md`（專案段落 + 工作流程章節）、`CLAUDE.md`（`@AGENTS.md`）
4. 驗證並列出建立了什麼；不會自動 commit

只想裝 `os-tickets`：

```bash
npx skills@latest add AlanSquid/agent-workflow -s os-tickets -a claude-code codex pi -y
```

## 日常流程（摘要）

| 規模 | 流程 |
| --- | --- |
| 小 | `/opsx:propose` → `/opsx:apply` → `/opsx:archive` |
| 中 | `/grill-with-docs` → `/opsx:propose` → `/implement`（`/tdd`、`/code-review`）→ `/opsx:archive` |
| 大 | `/grill-with-docs` → `/opsx:propose` → `/os-tickets` → 每張票新 session `/implement` → `/opsx:archive` |

完整規則由 `bootstrap-workflow` 寫進各專案的 `AGENTS.md`。

## 更新

```bash
npx skills@latest update      # 更新專案裡的 Pocock skills 與 os-tickets
npx skills@latest check       # 只檢查有沒有新版
```

不要手動修改 `.agents/skills/` 裡的檔案，`update` 會直接覆蓋。要改 `os-tickets` 的行為，改這個 repo 再 `update`。

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
└── os-tickets/
    └── SKILL.md
```
