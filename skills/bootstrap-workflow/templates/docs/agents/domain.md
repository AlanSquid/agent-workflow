# Domain Docs

工程 skills 探索程式碼時，如何讀取本專案的領域文件。

## 探索前先讀

- 根目錄的 **`CONTEXT.md`**：領域用語（glossary）
- **`docs/adr/`**：要動到的區域相關的 ADR

檔案不存在就直接繼續，不要提出「先建立它」。`/domain-modeling`（經由 `/grill-with-docs` 和
`/improve-codebase-architecture` 觸發）會在用語或決策真正定案時才建立或更新它們。

## 與 OpenSpec、需求文件的分工

幾份文件都在描述「這個專案是什麼」，各自守好自己的範圍，不要再新增一套：

- 需求文件（位置見 `AGENTS.md`）：業務規則的來源
- `openspec/specs/`：已接受的行為規格（`/opsx:archive` 後併入）
- `CONTEXT.md`：只放用語定義，不要把行為規則複製進去
- `docs/adr/`：工程決策；每份 ADR 要引用促成它的 OpenSpec change 或需求章節

## 檔案結構

```text
/
├── CONTEXT.md
├── docs/adr/
│   └── 0001-xxx.md
└── src/
```

## 使用 glossary 的用語

輸出中提到領域概念時（票的標題、重構提案、假設、測試名稱），一律使用 `CONTEXT.md` 定義的詞，
不要換成 glossary 明確列為避免使用的同義詞。

需要的概念還不在 glossary 裡，代表兩種可能：你在發明專案沒在用的說法（重新考慮），或是 glossary
真的有缺口（記下來交給 `/domain-modeling`）。

## 標出與 ADR 的衝突

如果輸出跟既有 ADR 矛盾，要明確指出，不要悄悄覆蓋：

> _與 ADR-0002 矛盾，但值得重新討論，因為……_
