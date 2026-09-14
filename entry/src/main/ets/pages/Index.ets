import common from '@ohos.app.ability.common';
import { PlantModel } from '../common/models/PlantModel';
import { SpeciesModel } from '../common/models/SpeciesModel';
import { CareLogModel } from '../common/models/CareLogModel';
import { DiaryModel } from '../common/models/DiaryModel';
import { StorageService } from '../common/database/StorageService';
import { ThemeManager } from '../theme/ThemeManager';
import { DateUtil } from '../common/utils/DateUtil';
import { CareTaskItem } from '../common/utils/CareScheduler';

// 视图导入
import { HomeTab } from '../views/HomeTab';
import { GardenTab } from '../views/GardenTab';
import { CalendarTab } from '../views/CalendarTab';
import { WikiTab } from '../views/WikiTab';
import { ProfileTab } from '../views/ProfileTab';

interface TabItemConfig {
  index: number;
  icon: string;
  title: string;
}

@Entry
@Component
struct Index {
  @StorageProp('currentColorMode') systemColorMode: number = 0;

  // 全局数据状态
  @State plants: PlantModel[] = [];
  @State speciesList: SpeciesModel[] = [];
  @State careLogs: CareLogModel[] = [];
  @State diaries: DiaryModel[] = [];
  @State streakDays: number = 0;

  // 主题与交互状态
  @State currentTabIndex: number = 0;
  @State isDark: boolean = false;
  @State themeMode: string = 'light';

  private tabController: TabsController = new TabsController();
  private tabItems: TabItemConfig[] = [
    { index: 0, icon: '🌸', title: '今日' },
    { index: 1, icon: '🪴', title: '花园' },
    { index: 2, icon: '📅', title: '日历' },
    { index: 3, icon: '📚', title: '百科' },
    { index: 4, icon: '🏮', title: '雅舍' }
  ];

  aboutToAppear(): void {
    // 1. 初始化存储
    try {
      const ctx = this.getUIContext()?.getHostContext() as common.UIAbilityContext;
      StorageService.getInstance().init(ctx);
    } catch (e) {
      StorageService.getInstance().init();
    }

    // 2. 初始化主题
    ThemeManager.getInstance().init();
    this.themeMode = ThemeManager.getInstance().getThemeMode();
    this.updateDarkModeState();

    // 3. 读取并刷新数据
    this.refreshData();
  }

  onPageShow(): void {
    this.refreshData();
    this.updateDarkModeState();
  }

  private updateDarkModeState(): void {
    ThemeManager.getInstance().setSystemDark(this.systemColorMode === 0);
    this.isDark = ThemeManager.getInstance().isDark();
  }

  private refreshData(): void {
    const storage = StorageService.getInstance();
    this.plants = [...storage.getPlants()];
    this.speciesList = [...storage.getSpecies()];
    this.careLogs = [...storage.getCareLogs()];
    this.diaries = [...storage.getDiaries()];

    // 计算连续打卡
    const careDates = this.careLogs.map(l => l.date);
    this.streakDays = DateUtil.calculateStreak(careDates);
  }

  // ================= 养护与打卡核心逻辑 =================

  private handleQuickCare(task: CareTaskItem): void {
    const today = DateUtil.formatDate();
    const time = DateUtil.formatTime();
    const log: CareLogModel = {
      id: `log_${Date.now()}`,
      plantId: task.plantId,
      plantName: task.nickname,
      actionType: task.actionType,
      actionName: task.actionName,
      date: today,
      time: time,
      note: '首页快捷完成打卡'
    };
    StorageService.getInstance().addCareLog(log);
    this.refreshData();
  }

  private handlePlantCareAction(plant: PlantModel, actionType: string, actionName: string): void {
    const today = DateUtil.formatDate();
    const time = DateUtil.formatTime();
    const log: CareLogModel = {
      id: `log_${Date.now()}`,
      plantId: plant.id,
      plantName: plant.nickname,
      actionType: actionType,
      actionName: actionName,
      date: today,
      time: time,
      note: `为${plant.nickname}进行${actionName}`
    };
    StorageService.getInstance().addCareLog(log);
    this.refreshData();
  }

  private handlePastCareLog(plant: PlantModel, actionType: string, dateStr: string): void {
    const actionName = actionType === 'water' ? '浇水' : (actionType === 'fertilize' ? '施肥' : '修剪');
    const log: CareLogModel = {
      id: `log_${Date.now()}`,
      plantId: plant.id,
      plantName: plant.nickname,
      actionType: actionType,
      actionName: actionName,
      date: dateStr,
      time: '12:00',
      note: '历史日期补记打卡'
    };
    StorageService.getInstance().addCareLog(log);
    this.refreshData();
  }

  // ================= 主题切换 =================

  private handleChangeThemeMode(mode: string): void {
    ThemeManager.getInstance().setThemeMode(mode);
    this.themeMode = mode;
    this.updateDarkModeState();
  }

  private handleToggleTheme(): void {
    const nextMode = this.isDark ? 'light' : 'dark';
    this.handleChangeThemeMode(nextMode);
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      // 1. 全屏背景底色
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(this.isDark ? '#100D1C' : '#FAF6F0')

      // 2. 主体 Tabs 内容
      Tabs({ barPosition: BarPosition.End, controller: this.tabController, index: this.currentTabIndex }) {
        // Tab 0: 今日
        TabContent() {
          HomeTab({
            isDark: this.isDark,
            plants: this.plants,
            careLogs: this.careLogs,
            diaries: this.diaries,
            streakDays: this.streakDays,
            onSwitchTab: (idx: number) => {
              this.currentTabIndex = idx;
              this.tabController.changeIndex(idx);
            },
            onQuickCare: (task: CareTaskItem) => {
              this.handleQuickCare(task);
            },
            onToggleTheme: () => {
              this.handleToggleTheme();
            }
          })
        }

        // Tab 1: 我的花园
        TabContent() {
          GardenTab({
            isDark: this.isDark,
            plants: this.plants,
            onQuickWater: (p: PlantModel) => {
              this.handlePlantCareAction(p, 'water', '浇水');
            }
          })
        }

        // Tab 2: 养护日历
        TabContent() {
          CalendarTab({
            isDark: this.isDark,
            careLogs: this.careLogs,
            diaries: this.diaries,
            plants: this.plants,
            onAddPastCareLog: (p: PlantModel, act: string, dStr: string) => {
              this.handlePastCareLog(p, act, dStr);
            }
          })
        }

        // Tab 3: 百花图鉴
        TabContent() {
          WikiTab({
            isDark: this.isDark,
            speciesList: this.speciesList
          })
        }

        // Tab 4: 雅舍与成就设置
        TabContent() {
          ProfileTab({
            isDark: this.isDark,
            themeMode: this.themeMode,
            plants: this.plants,
            careLogs: this.careLogs,
            diaries: this.diaries,
            streakDays: this.streakDays,
            onChangeThemeMode: (m: string) => {
              this.handleChangeThemeMode(m);
            },
            onDeleteDiary: (id: string) => {
              StorageService.getInstance().deleteDiary(id);
              this.refreshData();
            },
            onResetData: () => {
              StorageService.getInstance().resetToSampleData();
              this.refreshData();
            },
            onImportData: (jsonStr: string) => {
              const ok = StorageService.getInstance().importDataFromJson(jsonStr);
              if (ok) {
                this.refreshData();
              }
            }
          })
        }
      }
      .scrollable(false)
      .barHeight(0)
      .animationDuration(300)
      .onChange((index: number) => {
        this.currentTabIndex = index;
      })
      .width('100%')
      .height('100%')

      // 3. 悬浮毛玻璃胶囊导航栏（保持琉璃花语金雅色调，液态玻璃拟态质感）
      Row({ space: 4 }) {
        ForEach(this.tabItems, (item: TabItemConfig) => {
          Column({ space: 2 }) {
            Text(item.icon)
              .fontSize(18)
              .scale({
                x: this.currentTabIndex === item.index ? 1.15 : 1.0,
                y: this.currentTabIndex === item.index ? 1.15 : 1.0
              })
              .animation({ duration: 200, curve: Curve.EaseInOut })

            Text(item.title)
              .fontSize(11)
              .fontWeight(this.currentTabIndex === item.index ? FontWeight.Bold : FontWeight.Medium)
              .fontColor(
                this.currentTabIndex === item.index
                  ? (this.isDark ? '#D4B87E' : '#8A5D18')
                  : (this.isDark ? '#8A85A4' : '#6B6780')
              )
          }
          .layoutWeight(1)
          .height('100%')
          .justifyContent(FlexAlign.Center)
          .borderRadius(22)
          .backgroundColor(
            this.currentTabIndex === item.index
              ? (this.isDark ? 'rgba(212, 184, 126, 0.20)' : 'rgba(201, 169, 110, 0.18)')
              : Color.Transparent
          )
          .stateStyles({
            pressed: {
              .scale({ x: 0.94, y: 0.94 })
              .opacity(0.85)
            },
            normal: {
              .scale({ x: 1.0, y: 1.0 })
              .opacity(1.0)
            }
          })
          .animation({ duration: 150, curve: Curve.EaseOut })
          .onClick(() => {
            this.currentTabIndex = item.index;
            this.tabController.changeIndex(item.index);
          })
        }, (item: TabItemConfig) => item.index.toString())
      }
      .width('92%')
      .height(58)
      .padding({ left: 6, right: 6, top: 4, bottom: 4 })
      .borderRadius(29)
      .backgroundColor(this.isDark ? 'rgba(28, 24, 42, 0.85)' : 'rgba(255, 255, 255, 0.92)')
      .backgroundBlurStyle(
        this.isDark ? BlurStyle.Regular : BlurStyle.Thin,
        { colorMode: this.isDark ? ThemeColorMode.DARK : ThemeColorMode.LIGHT }
      )
      .backdropBlur(25)
      .shadow({
        radius: 20,
        color: this.isDark ? 'rgba(0, 0, 0, 0.40)' : 'rgba(168, 135, 74, 0.12)',
        offsetX: 0,
        offsetY: 4
      })
      .border({
        width: 1,
        color: this.isDark ? 'rgba(212, 184, 126, 0.22)' : 'rgba(255, 255, 255, 0.95)'
      })
      .margin({ bottom: 18 })
    }
    .width('100%')
    .height('100%')
  }
}