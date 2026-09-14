# 🌸 琉璃花语 · Liuli Huayu

> **以琉璃为器，以花语为引。守护你的绿意时光。**
> 
> 一部完全免费、完全单机、无账号体系的鸿蒙原生养花日记与百科应用。

---

## 🌟 核心特性

- 🎁 **完全免费**：无买断费、无订阅、无内购、无任何形式的商业化限制与广告。
- 🔒 **完全单机**：不依赖网络，不申请网络权限，数据全部存储于本机沙盒，离线随时可用。
- 🚫 **无用户系统**：无账号、无注册，开箱即用，零门槛守护绿意。
- 🌓 **深色模式适配**：全面遵循鸿蒙系统深色设计规范，日间柔光，夜间沉静，支持随系统自动切换或手动常开。
- 💎 **液态玻璃美学**：采用 琉璃微透拟态 拟态设计语言与东方花语色彩（琉璃金、紫罗兰、落樱粉、薄荷绿）。
- 🌿 **百种名花百科**：预置离线花种百科库，涵盖光照、水温、土壤、繁殖与病虫害诊断。
- 💧 **智能养护打卡**：支持浇水、施肥、喷雾、修剪一键记录，智能推算下次周期，支持 7 天内历史补记。
- 📅 **养护日历与热力图**：月度日历事件足迹与坚持频率热力图。
- 🏆 **成就勋章馆**：五大维度、12+ 枚成就徽章，激励长期陪伴。
- 📦 **本地数据备份**：支持全量 JSON 数据导出与导入恢复。

---

## 🏗️ 技术架构

- **操作系统**：HarmonyOS NEXT / HarmonyOS 5.0+ (API 12 ~ API 24)
- **开发语言**：ArkTS (声明式 UI，严格模式)
- **模型架构**：Stage 模型
- **存储机制**：本地沙盒文件持久化 (`@ohos.file.fs`)

---

## 📂 工程结构

```
entry/src/main/ets/
├── common/
│   ├── components/                 # 通用拟态 UI 组件 (GlassCard, StatBadge, EmptyState)
│   ├── constants/                  # 主题色表与预置百花百科库 (ThemeConstants, DefaultWikiData)
│   ├── database/                   # 本地沙盒持久化服务 (StorageService)
│   ├── models/                     # 严格类型定义 (Plant, Species, CareLog, Diary, Badge)
│   └── utils/                      # 周期推算、徽章计算、日历工具 (CareScheduler, BadgeEngine, DateUtil)
├── dialogs/                        # 交互弹窗 (AddPlant, PlantDetail, SpeciesDetail, AddDiary, ShareSummary)
├── theme/                          # 深色/浅色模式控制器 (ThemeManager)
├── views/                          # 五大主 Tab 视图 (HomeTab, GardenTab, CalendarTab, WikiTab, ProfileTab)
└── pages/
    └── Index.ets                   # 根页面
```

---

## 🚀 编译与构建

在 DevEco Studio 中打开工程，或在命令行使用 Hvigor 构建：

```bash
# 编译 HAP
hvigorw assembleHap

# 编译整包 APP
hvigorw assembleApp
```
