# 🎬 SRT Subtitle Processor

*A native macOS app for professional SRT subtitle cleanup, merging, and splitting.*

<p align="center">
  <img src="https://img.shields.io/badge/platform-macOS_13+-lightgrey?logo=apple" />
  <img src="https://img.shields.io/badge/swift-5.7+-F05138?logo=swift" />
  <img src="https://img.shields.io/badge/xcode-14.3+-147EFB?logo=xcode" />
  <img src="https://img.shields.io/badge/status-private software-red" />
  <img src="https://img.shields.io/badge/license-restricted-important" />
</p>

---

## 📘 Overview

**SRT Subtitle Processor** is a native macOS application built with SwiftUI, designed to clean, merge, split, and normalize `.srt` subtitle files.
It provides **real-time preview**, **statistical analysis**, and **high-precision algorithms** for smoothing fragmented subtitles or splitting long blocks of text.

The app focuses on solving two common problems:

* **Over-fragmentation:** subtitles with extremely short gaps that harm readability.
* **Overlong durations:** subtitles that stay on screen too long or contain too much text.

---

## 🚀 Features at a Glance

| Feature                     | Description                                                                          |
| --------------------------- | ------------------------------------------------------------------------------------ |
| 🔄 **Smart Merge**          | Merges consecutive subtitles based on configurable time gaps (millisecond precision) |
| ✂️ **Configurable Split**   | Splits long subtitles using duration limits or punctuation-aware methods             |
| 📊 **Real-Time Statistics** | Live metrics: averages, standard deviation, min/max durations                        |
| ⚡ **Async Processing**      | Uses Swift Concurrency to avoid UI blocking on large files                           |
| 🖥️ **Instant Preview**     | Visualises all modifications before saving                                           |
| ♻️ **Undo/Backup System**   | Full history stack enabling rollback of any applied change                           |
| 🧪 **Mock/Test Mode**       | Generate test subtitles with a single click                                          |
| 🧩 **SwiftUI Architecture** | Clear MVVM structure for maintainability & scalability                               |

---

## 📁 Project Structure (MVVM)

```
SRTMerger/
├── App/
│   ├── SRTMergerApp.swift
│   └── AppDelegate.swift
├── View/
│   ├── ContentView.swift
│   ├── SubtitleRowView.swift
│   └── StatisticBox.swift
├── ViewModel/
│   └── AppViewModel.swift
├── Model/
│   ├── Subtitle.swift
│   ├── ProcessingMode.swift
│   └── SplitMethod.swift
└── Helpers/
    └── MockDataGenerator.swift
```

---

## 🧰 Requirements

* **macOS** 13.0 Ventura or later
* **Xcode** 14.3 or later
* **Swift** 5.7 or later
* Apple Silicon **(M1/M2/M3)** or Intel Mac

---

## 🔧 Installation & Build Instructions

### 1. Clone the Repository

```sh
git clone https://github.com/carlneto/SRTSubtitleProcessor.git
cd SRTSubtitleProcessor
```

### 2. Open the Project

```sh
open SRTSubtitleProcessor.xcodeproj
```

### 3. Build & Run

Select the scheme **SRTMergerApp** → press **⌘R**.

---

## 🖱️ How to Use

1. **Load a File**

   * Click **“Select File”** or use **“Test Data”**.

2. **Choose the Mode**

   * **Merge:** unify subtitles with short gaps.
   * **Split:** divide long subtitles.

3. **Adjust Parameters**

   * Maximum time gap (Merge)
   * Maximum duration or splitting method (Split)

4. **Analyse Changes**
   View statistics such as duration distribution, mean, deviation, etc.

5. **Preview the Results**

6. **Save**

   * **Apply Changes** – commits in-app changes
   * **Save Processed** – exports cleaned `.srt`
   * **Save Marked** – debug export
   * **Restore Backup** – undo last applied change

---

## 🧠 Technical Notes

* Built entirely with **SwiftUI**
* Heavy use of **Swift Concurrency** (`Task`, `async/await`)
* Algorithmic precision up to **1 ms**
* Designed to handle large subtitle sets efficiently

---

## 🔒 License

**⚠️ PROPRIETARY AND RESTRICTED LICENSE**
*Not Open Source.*

Summary:

* ❌ Redistribution forbidden
* ❌ Reverse engineering forbidden
* ❌ Modifying or creating derivative works forbidden
* ❌ Commercial use forbidden
* ✅ Personal use for evaluation/testing allowed

© 2025 – All rights reserved.

---

## 👤 Author

**Developer:** carlneto
**Tech stack:** SwiftUI, Swift Concurrency, macOS frameworks

---

## ⭐ Support & Feedback

Since this is a private project, discussions and issue tracking are not publicly available.
If you need improvements, suggestions or additional documentation—just ask!
