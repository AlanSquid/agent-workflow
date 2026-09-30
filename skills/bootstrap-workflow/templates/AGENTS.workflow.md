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
| 小（一個 session 能做完、行為變動很小） | 直接 `/opsx:propose` → `/opsx:apply` → `/opsx:archive`，或 grill 完直接實作 |
| 中（一個 change、行為差異明確） | `/grill-with-docs` → `/opsx:propose` → `/implement`（搭配 `/tdd`、`/code-review`）→ `/opsx:archive`，不拆票 |
| 大（跨多個 session、跨多層） | `/grill-with-docs` → `/opsx:propose` → `/os-tickets` → 每張票各開新 session 跑 `/implement` → `/opsx:archive` |
| 純基礎設施 | 照工作本身的結構拆，不硬套垂直切片 |

避免兩套系統脫節的規則：

- 拆票一律走 `/os-tickets`（橋接 skill），不要直接用 `/to-tickets`。它依照 to-tickets 的方法，
  但把 task group 寫進 `openspec/changes/<change>/tasks.md`
- grill 完直接在同一個 session 接 `/opsx:propose`；本專案刻意不裝 `/to-spec`，spec 由 OpenSpec 負責。
  grilling 不取代 `/opsx:explore`，後者在 change 進行中當思考夥伴
- `/implement` 要講清楚做哪份 change 的哪一組，並要求打勾，例如：
  `/implement openspec/changes/<change> 第 1 組。完成一項就在 tasks.md 打勾。`
- 呼叫 `/code-review` 時，把 change 的路徑（`openspec/changes/<change>/`）當作 spec 來源傳進去
- `/domain-modeling` 的產出放在 `docs/agents/domain.md` 規定的固定位置（根目錄 `CONTEXT.md` 加上 `docs/adr/`）
- 不要修改 `.agents/skills/` 裡的上游 skill（`npx skills update` 會直接覆蓋，不會合併）
- Context 管理：規劃（grill → propose → tickets）在同一個 session 完成；每張票的 `/implement`
  各開新 session；規劃 session 接近約 120k tokens 時用 `/handoff`
- 定期跑 `/improve-codebase-architecture`，把選定的項目經 `/grill-with-docs` → `/opsx:propose` 回到主流程

## Agent skills

### Issue tracker

票就是 `openspec/changes/<change>/tasks.md` 裡的 task group，由 `/os-tickets` 寫入。
詳見 `docs/agents/issue-tracker.md`。

### Domain docs

單一 context：根目錄一份 `CONTEXT.md`，加上 `docs/adr/`。詳見 `docs/agents/domain.md`。
