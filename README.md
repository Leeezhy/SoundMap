# SoundMap: Elevation-Aware Spatial Audio Navigation

[![](https://img.shields.io/badge/based_on-Soundscape-blue.svg)](https://github.com/soundscape-community/soundscape)
[![](https://img.shields.io/badge/status-in%20research-yellow.svg)]()
[![](https://img.shields.io/badge/author-Leezzhy-blueviolet.svg)]()

SoundMap is a research-oriented fork of [Soundscape Community](https://github.com/soundscape-community/soundscape), aiming to explore **how spatial audio can be used to express elevation**—such as slopes, stairs, and floor levels—during walking navigation.

> 🧭 "What if you could not only hear where something is, but also how high or low it is?"

---

## 🧠 Research Focus / 研究目标

Traditional navigation apps focus on 2D directions (left/right, forward/backward).  
**SoundMap adds a third dimension: vertical awareness.**

In this project, we investigate:

- How can we **sonify height, slope, or vertical transitions** in a way that’s intuitive and ambient?
- How might blind or sighted users benefit from **elevation-aware sound cues**?
- What role can auditory design play in building **spatial confidence**?

---

### ✨ 中文说明（项目背景）

本项目基于 Soundscape 社区开源版本进行改造，研究重点为：

- ✅ 在空间音频基础上，进一步通过声音表达**地形起伏**和**高度信息**
- ✅ 例如：上坡、下坡、上下楼、地下空间等的可听觉化表达
- ✅ 探索声音如何帮助步行用户建立“垂直空间的认知地图”
- ✅ 兼顾无障碍设计与通用设计，提升普通人对空间的直觉导航能力

---

## 🔊 Sound Design Strategy

| Elevation State               | Auditory Feedback Design                       |
| ----------------------------- | ---------------------------------------------- |
| Uphill                        | Gradual pitch increase, lighter tone           |
| Downhill                      | Pitch fall, low-pass filter, weighted footstep |
| Going Upstairs                | Per-step bell tone, ascending scale            |
| Going Downstairs              | Descending percussive tones                    |
| Flat Terrain                  | Stable mid-tone ambient hum                    |
| Underground / Basement        | Echo/reverb added to simulate closed space     |
| High Altitude (e.g., rooftop) | Airy, open spatial filter                      |

> These sounds are **non-intrusive**, ambient, and designed to run in the background—without disrupting podcasts, calls, or screen readers.

---

## 📦 Based On

This project builds on:

- [Microsoft Soundscape (archived)](https://github.com/microsoft/soundscape)
- [soundscape-community](https://github.com/soundscape-community/soundscape)

Original Soundscape explored spatial awareness through 3D audio.  
SoundMap extends this concept into **vertical space**.

---

## 📱 Building the Project (iOS)

1. Clone this repo
2. Follow [iOS build instructions from upstream](https://github.com/soundscape-community/soundscape/wiki/build-tips)
3. Use your own Apple ID for code signing
4. Remove restricted capabilities (iCloud, Push Notification, Associated Domains) if needed
5. Build and run on a physical iPhone (required for spatial audio + motion sensing)

---

## 🛠 Development Goals

- [x] Restructure code to isolate height sonification modules
- [x] Design baseline set of height-aware sound cues
- [ ] Integrate with CoreMotion or GPS altimeter
- [ ] Conduct user studies for perception validation
- [ ] Export sound events for data analysis

---

## 🤝 Collaboration

This project is part of an academic research effort.  
I'm currently exploring sound design, accessibility, and ambient navigation experiences.

If you're interested in spatial UI, auditory interaction, or HCI design—feel free to [open an issue](https://github.com/Leezzhy/SoundMap/issues), or just say hi!

---

## 🧭 License & Attribution

MIT License.  
Credits to Microsoft Soundscape and the soundscape-community contributors.  
All modified components are clearly marked.

---

## 💡 Inspiration

> "Good design is not only how something looks—but how it **sounds**, and how it **guides** you without speaking a word."
