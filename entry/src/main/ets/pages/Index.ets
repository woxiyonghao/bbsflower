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
  @State themeMode: string = 'system';

  private tabController: TabsController = new TabsController();

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

  // ================= TabBar 自定义样式 =================

  @Builder
  TabBuilder(title: string, targetIndex: number, icon: string) {
    Column({ space: 3 }) {
      Text(icon)
        .fontSize(this.currentTabIndex === targetIndex ? 20 : 18)

      Text(title)
        .fontSize(11)
        .fontWeight(this.currentTabIndex === targetIndex ? FontWeight.Bold : FontWeight.Normal)
        .fontColor(
          this.currentTabIndex === targetIndex
            ? (this.isDark ? '#D4B87E' : '#A8874A')
            : (this.isDark ? '#736F90' : '#8E8AA3')
        )
    }
    .width('100%')
    .height(52)
    .justifyContent(FlexAlign.Center)
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      // 1. 液态玻璃环境渐变背景
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
        .tabBar(this.TabBuilder('今日', 0, '🌸'))

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
        .tabBar(this.TabBuilder('花园', 1, '🪴'))

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
        .tabBar(this.TabBuilder('日历', 2, '📅'))

        // Tab 3: 百花图鉴
        TabContent() {
          WikiTab({
            isDark: this.isDark,
            speciesList: this.speciesList
          })
        }
        .tabBar(this.TabBuilder('百科', 3, '📚'))

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
        .tabBar(this.TabBuilder('雅舍', 4, '🏮'))
      }
      .barHeight(64)
      .barBackgroundColor(this.isDark ? 'rgba(25, 20, 36, 0.92)' : 'rgba(255, 255, 255, 0.92)')
      .barMode(BarMode.Fixed)
      .onChange((index: number) => {
        this.currentTabIndex = index;
      })
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
  }
}