# 佈局結構分析

頁面以一個主容器 <div class="max-w-sm mx-auto bg-white h-screen flex flex-col"> 包裹，分為 header、main、footer 三大區塊。

## 主要區域
<main class="flex-grow ...">：為主要內容區域，顯示卡路里、營養素進度條、今日數據等。

## 次要區域
<header class="p-4 ...">：頁首，包含返回按鈕、標題、用戶頭像。
<footer class="bg-white ...">：頁尾，包含導航按鈕（Home, Diary, Add, Trends, Settings）。

## 輔助區域
主內容中的「SEE STATS」按鈕、主內容下方的營養素進度條、今日數據等，屬於輔助資訊與操作。

## 導航區域
<footer> 內的多個 <a> 標籤，分別對應不同頁面（Home, Diary, Trends, Settings），以及中央的新增按鈕。

## 內容區域
<main> 內的卡路里圓環、營養素進度條、今日攝取數據等，為主要內容展示。

## 操作區域
「SEE STATS」按鈕、footer 中的新增（Add）按鈕，以及 footer 其他導航按鈕。

## 提示區域
主要內容區域中的「KCAL LEFT」、「EATEN」、「BURNED」等文字提示，以及營養素進度條下方的數據說明。

