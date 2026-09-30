# Issue tracker：OpenSpec changes（本地 markdown）

本專案的票放在 `openspec/changes/` 底下的 OpenSpec change 文件裡，沒有另外的票券目錄。
OpenSpec 管文件，工程 skills 把它們的紀律插進去（見 `AGENTS.md` 的「混合工作流程」）。

## 東西放在哪裡

- 一件工作的 spec 就是它的 OpenSpec change：`openspec/changes/<change>/`（`proposal.md`
  加上 delta specs），用 `/opsx:propose` 建立。skill 要找「spec」時，讀 change 的文件，
  沒有獨立的 `spec.md`
- 票是 `openspec/changes/<change>/tasks.md` 裡的 task group：一組就是一個 tracer-bullet 垂直切片，
  有編號，每組都有 `Blocked by:` 標註。沒有每張票各自的檔案
- 票的狀態就是該組任務的 checkbox 狀態

## skill 說「發布到 issue tracker」時

票在 `/opsx:propose` 產生 tasks.md 時就切好了：`openspec/config.yaml` 的 `rules.tasks` 要求照 to-tickets
的切片方法寫，但輸出只寫進 `openspec/changes/<change>/tasks.md`。不要直接呼叫 `/to-tickets`，也不要發布到
任何外部 tracker。change 還不存在時，先用 `/opsx:propose` 建立。

要重切既有 change 的票（例如 design 改了）：先跑 `openspec instructions tasks --change <change>` 取得同一套
rules，照它重寫 tasks.md，已打勾的任務保留。

## skill 說「取得相關的票」時

讀 `openspec/changes/<change>/tasks.md` 裡指定的 task group。使用者通常會給 change 名稱和組別編號。

## commit 訊息裡的票號

commit 訊息標題結尾的「（change: X，第 N 組）」就是票號，代表 `openspec/changes/X/tasks.md` 的第 N 組；
對應的 spec 是同一個 change 資料夾裡的 proposal、specs、design。`/code-review` 從 commit 訊息找 spec 時照這個對應去讀。
change 已經 archive 的話，到 `openspec/changes/archive/` 底下找名稱結尾是 X 的資料夾。

## 臨時工作檔

不屬於任何 change 的工作檔（探索筆記、handoff 紀錄）放在 `.scratch/`，它不在追蹤系統裡，也不進 git。
