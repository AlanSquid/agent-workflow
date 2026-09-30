## OpenSpec 工作流程

本專案用 [OpenSpec](https://github.com/Fission-AI/OpenSpec)（`schema: spec-driven`，設定在
`openspec/config.yaml`）管理變更。進行中的變更放在 `openspec/changes/<name>/`，完成後移到
`openspec/changes/archive/`；已接受的 spec 放在 `openspec/specs/`。

Slash commands：`/opsx:propose`、`/opsx:explore`、`/opsx:apply`、`/opsx:archive`。

## 混合工作流程：OpenSpec × 工程 skills

OpenSpec 是文件骨架（長期的「做什麼」）；`.agents/skills/` 裡的工程 skills（Matt Pocock skills）
是插進去的紀律（「怎麼做」）。每個變更先依下表選擇流程：

| 規模 | 流程 |
| --- | --- |
| 小（一個 session 能做完、行為變動很小） | `/opsx:propose` → `/opsx:apply` → `/opsx:archive` |
| 中（一個 change、行為差異明確） | `/grill-with-docs` → `/opsx:propose` → `/opsx:apply` 整份 change → `/opsx:archive` |
| 大（跨多個 session、跨多層） | `/grill-with-docs` → `/opsx:propose`（tasks.md 的每個 task group 就是一張票）→ 每張票各開新 session 跑 `/opsx:apply <change> 只做第 N 組` → `/opsx:archive` |
| 純基礎設施 | 照工作本身的結構拆，不硬套垂直切片 |

避免兩套系統脫節的規則：

- 拆票在 `/opsx:propose` 產生 tasks.md 時完成：`openspec/config.yaml` 的 `rules.tasks` 要求照 to-tickets
  的切片方法寫，並在超過一組時先請你確認切法。不要直接用 `/to-tickets`（它會發布到 `.scratch/` 或外部 tracker）。
  要重切時見 `docs/agents/issue-tracker.md`
- proposal 階段若有會改變 specs 或拆法的未決事項，agent 會依 grilling 的方式停下來問（`rules.proposal`）；
  已經先跑過 `/grill-with-docs` 就不會重問
- grill 完直接在同一個 session 接 `/opsx:propose`；本專案刻意不裝 `/to-spec`，spec 由 OpenSpec 負責。
  grilling 不取代 `/opsx:explore`，後者在 change 進行中當思考夥伴
- **實作 OpenSpec change 的任務時**（不論用 `/opsx:apply` 或 `/implement`）。`openspec/config.yaml` 的 rules
  管不到 apply 階段，這條規則是實作紀律的唯一來源：
  - 寫新行為前用 Skill tool 載入 `tdd` skill，照它的紅綠循環做：先寫會因「行為不符」而失敗的測試並實際跑過、
    確認紅燈，才寫實作；一次一個測試。接縫以 tasks.md 該組列出的為準，沒列到的新接縫先問使用者
  - 每完成一項：在 tasks.md 打勾，測試全綠就 commit（一項一個 commit，不要整組最後一次打勾或 commit）
  - commit 訊息的標題結尾附上「（change: <change>，第 N 組）」，例如
    `feat: default 設定逐筆相同（change: supertrend-backtest-parity，第 5 組）`。
    不要寫成 `<change>#N`：GitHub 會把 `#N` 當成 issue 編號
  - 每完成一個 task group：用 `/code-review` 審查這組第一個 commit 以來的變更（包含這組對其他 repo 的
    commit），傳入 `openspec/changes/<change>/` 當 spec 來源；review 的修正另外 commit
- 實作預設用 `/opsx:apply`：它會自動讀 proposal、specs、design、tasks 並打勾。大型變更要講清楚只做哪一組，
  否則它會一路做完全部。`/implement` 也可以用，但要自己交代 change 路徑與打勾，例如：
  `/implement openspec/changes/<change> 第 1 組。完成一項就在 tasks.md 打勾。`
- 呼叫 `/code-review` 時，把 change 的路徑（`openspec/changes/<change>/`）當作 spec 來源傳進去
- `/domain-modeling` 的產出放在 `docs/agents/domain.md` 規定的固定位置（根目錄 `CONTEXT.md` 加上 `docs/adr/`）
- 不要修改 `.agents/skills/` 裡的上游 skill（`npx skills update` 會直接覆蓋，不會合併）
- Context 管理：規劃（grill → propose）在同一個 session 完成；每張票的實作
  各開新 session；規劃 session 接近約 120k tokens 時用 `/handoff`
- 定期跑 `/improve-codebase-architecture`，把選定的項目經 `/grill-with-docs` → `/opsx:propose` 回到主流程

## Agent skills

### Issue tracker

票就是 `openspec/changes/<change>/tasks.md` 裡的 task group，由 `/opsx:propose` 依 `rules.tasks` 寫入。
詳見 `docs/agents/issue-tracker.md`。

### Domain docs

單一 context：根目錄一份 `CONTEXT.md`，加上 `docs/adr/`。詳見 `docs/agents/domain.md`。
