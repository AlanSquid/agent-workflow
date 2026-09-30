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
- `rules.tasks`：照 `to-tickets` 的切片方法寫 tasks.md（每個 task group 就是一張票，超過一組先確認），但不執行它的發布步驟

`config.yaml` 只管 artifact 產生階段（proposal / specs / design / tasks），管不到 `/opsx:apply`；實作階段的 TDD 與 code review 由 `/implement`、`/tdd`、`/code-review` 負責。

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
   - 檢查 `to-tickets` 被 `rules.tasks` 引用的段落還在（上游改名時直接報錯）
   - `docs/agents/issue-tracker.md`、`docs/agents/domain.md`
2. 讀專案結構，分輪問你幾個決策問題：專案是什麼、需求文件在哪、誰擁有需求、這個專案的「一片垂直切片」怎麼驗收、會碰到哪些外部 API、常用指令、文件語言
3. 依回答寫入 `openspec/config.yaml` 的 `context` 與 `rules`、`AGENTS.md`（專案段落 + 工作流程章節）、`CLAUDE.md`（`@AGENTS.md`）
4. 驗證並列出建立了什麼；不會自動 commit

## 日常流程（摘要）

| 規模 | 流程 |
| --- | --- |
| 小 | `/opsx:propose` → `/opsx:apply` → `/opsx:archive` |
| 中 | `/grill-with-docs` → `/opsx:propose` → `/implement`（`/tdd`、`/code-review`）→ `/opsx:archive` |
| 大 | `/grill-with-docs` → `/opsx:propose`（task group 即票）→ 每張票新 session `/implement` → `/opsx:archive` |

完整規則由 `bootstrap-workflow` 寫進各專案的 `AGENTS.md`。

## 更新

```bash
npx skills@latest update      # 更新專案裡的 Pocock skills
npx skills@latest check       # 只檢查有沒有新版
```

不要手動修改 `.agents/skills/` 裡的檔案，`update` 會直接覆蓋。要調整 skill 在本流程裡的行為，改 `openspec/config.yaml` 的 `rules`。

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
