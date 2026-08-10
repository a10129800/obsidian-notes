---
初次更編寫: 2026/08/10
第一次更新:
---
## 目錄
- [[#🗺️ 今天整體流程|整體流程]]
	- [[#① 安裝與確認環境|① 安裝與確認環境]]
	- [[#② 建立 Quartz]]
	- [[#③ 遇到 Quartz Theme 錯誤]]
	- [[#④ Quartz 本機成功運作]]
	- [[#⑤ 我們解決了「只公開指定筆記」|⑤只公開指定筆記]]
	- [[#⑦ 解決 Foobar2000 筆記 404]]
	- [[#⑧ 建立 GitHub Repository]]
	- [[#⑨ Git Remote 出錯，但後來修好了]]
	- [[#⑩ Quartz 成功推到 GitHub]]
	- [[#⑪ 最後開始做 GitHub Pages]]
	- [[#⭐ 所以你現在進度在哪？]]
	
- [[#🧠 你今天其實學會了 5 個很重要的東西]]
	- [[#1. Quartz 是什麼？]]
	- [[#2. `publish true`|publish true]]
	- [[#3. Git]]
	- [[#4. GitHub]]
	- [[#5. GitHub Actions]]
 -[[#📌 以後你最常用的指令]]
#  把 Obsidian 筆記用 Quartz 做成網站，並準備發布到 GitHub Pages。

### 🗺️ 今天整體流程
Obsidian
   ↓
Quartz 5
   ↓
指定哪些筆記可以公開
   ↓
localhost 預覽
   ↓
Git / GitHub
   ↓
GitHub Actions
   ↓
GitHub Pages
   ↓
🌐 給別人看的網站

## ① 安裝與確認環境

(1)一開始已經有：
Git 2.54.0.windows.1 
Node.js v24.19.0 
npm 11.17.0

(2)Quartz 也成功安裝：@jackyzha0/quartz@5.0.0

=>所以環境是：Quartz 5.0.0 + Node.js 24 + Git

## ② 建立 Quartz

(1)Quartz 放在：C:\Users\mice\Desktop\Quartz

* 所以我們使用：
cmd
cd /d C:\Users\mice\Desktop\Quartz

* 然後初始化 Quartz。
選擇了：Configuration template: Obsidian

## ③ 遇到 Quartz Theme 錯誤

當時遇到：Cannot find module '@quartz-themes/default'
後來確認：@quartz-themes/default@1.0.1確實存在，
而且：require.resolve('@quartz-themes/default')可以找到：node_modules/@quartz-themes/default/theme.json
所以最後確認這不是「套件不存在」的問題。
這部分最後沒有阻止 Quartz 正常運作。

## ④ Quartz 本機成功運作

最後你成功執行npx quartz build --serve

看到：
```
Started a Quartz server listening at http://localhost:8080
```

這代表：

> **Quartz 已經可以在你的電腦上當網站跑。**

`localhost:8080` 是**只有你自己的電腦可以看的測試網站**。

## ⑤ 我們解決了「只公開指定筆記」

你不希望：

> Obsidian 裡所有筆記全部被公開。

所以我們採用了：
```
publish: true
```
只有有這個設定的筆記才公開。

## ⑥ 解決首頁問題

我們把 `index.md` 做成首頁。

希望：
> 首頁不要放自己的名稱。

而是：
> **筆記分類與導覽**

所以首頁變成比較像個人知識庫：
```
筆記

這裡整理我的學習、技術研究、閱讀紀錄與各種資料。

📚 筆記分類

🎵 音樂與播放器
💻 技術筆記
📖 閱讀筆記
🎨 創作與其他

🧭 導覽

📋 總整理
```
期間曾經遇到：
```
Cannot create property 'title' on string
```

這是 index.md Frontmatter 格式出錯。
後來修正後，Quartz 就能正常解析。

## ⑦ 解決 Foobar2000 筆記 404

有一篇：

```
Foobar2000語法
└── Music player
    └── 語法1.md
```

之前 Quartz 顯示：
```
[404] /foobar2000%E8%AA%9E%E6%B3%95/music-player/
```

後來我們發現核心問題是：
這篇筆記原本沒有被設定為公開。
所以你現在把 `語法1.md` 加上：
```
publish: true
```
之後它就會被 Quartz 建置。

## ⑧ 建立 GitHub Repository

你的 GitHub Repository 是：
[a10129800/my-notes](https://github.com/a10129800/my-notes?utm_source=chatgpt.com)

我們把本機：

```
C:\Users\mice\Desktop\Quartz
```

連到：

```
GitHub
└── a10129800/my-notes
```

## ⑨ Git Remote 出錯，但後來修好了

一開始你的 `origin` 指到了：

```
https://github.com/jackyzha0/quartz.git
```

所以你 push 的時候得到：

```
Permission to jackyzha0/quartz.git denied
```

因為你當然沒有 Quartz 官方 Repository 的寫入權限。

我們後來改成：

```
git remote set-url origin https://github.com/a10129800/my-notes.git
```

這才是你的 Repository。

## ⑩ Quartz 成功推到 GitHub

最後成功：

```
[new branch] v5 -> v5
branch 'v5' set up to track 'origin/v5'
```

所以現在：

```
本機 Quartz
     ↓
    Git
     ↓
GitHub
     ↓
a10129800/my-notes
     ↓
    v5
```

已經連起來了。

而且：

```
git status
```

顯示：

```
On branch v5
Your branch is up to date with 'origin/v5'.

nothing to commit, working tree clean
```

這代表 Git 狀態乾淨。✅

## ⑪ 最後開始做 GitHub Pages

一開始你雖然啟用了 GitHub Pages，但網站：

```
https://a10129800.github.io/my-notes/
```

出現 404。

我們查看 Actions 後發現，原本的 workflow 並不是我們需要的正式 Pages 部署流程。

所以我們新增：

```
.github
└── workflows
    └── deploy.yml
```

內容負責：

```
Checkout
   ↓
安裝 Node
   ↓
npm ci
   ↓
npx quartz build
   ↓
產生 public/
   ↓
上傳 Pages artifact
   ↓
Deploy to GitHub Pages
```

然後你成功：

```
[v5 86c17d2] Add GitHub Pages deployment
```

並且：

```
v5 -> v5
```

已經 push 到 GitHub。✅

# ⭐ 所以你現在進度在哪？

現在已經到了最後一關：

```
                 今天完成
                     ↓
Obsidian ────────→ Quartz 5       ✅
                     ↓
               publish: true      ✅
                     ↓
              localhost:8080      ✅
                     ↓
                   Git            ✅
                     ↓
              GitHub Repository   ✅
                     ↓
             GitHub Actions       🟡
                     ↓
             GitHub Pages         ⏳
                     ↓
        https://a10129800.github.io/my-notes/
```

**現在最重要的就是 GitHub Actions。**

你剛剛 push 完 `deploy.yml`，所以現在要等：

```
Deploy Quartz to GitHub Pages
```

跑完。

如果：

```
🟢 Success
```

那今天整個流程就完成了。

如果：

```
🔴 Failed
```

就看錯誤訊息，我們再修。

## 🧠 你今天其實學會了 5 個很重要的東西

### 1. Quartz 是什麼？
把：

```
Obsidian Markdown
```

轉成：

```
HTML 網站
```

### 2. `publish: true`

控制：

> **這篇筆記要不要公開。**

### 3. Git

負責記錄：

你改了什麼

並把內容送到 GitHub。

### 4. GitHub

負責存放你的 Quartz 專案。

### 5. GitHub Actions

負責自動做：

你 push
   ↓
GitHub 自動執行
   ↓
Quartz build
   ↓
網站更新

所以以後你不需要自己手動把 HTML 上傳到網路。

## 📌 以後你最常用的指令

你之後修改 Obsidian 筆記，只要：
```
cd /d C:\Users\mice\Desktop\Quartz
git add .
git commit -m "Update notes"
git push
```

就可以。

如果新增要公開的筆記：

---
publish: true

如果不想公開：

不要加 publish: true。

這就是你之後最主要的工作流程。 🌱