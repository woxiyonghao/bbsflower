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

// 弹窗导入
import { AddPlantDialog } from '../dialogs/AddPlantDialog';
import { PlantDetailDialog } from '../dialogs/PlantDetailDialog';
import { SpeciesDetailDialog } from '../dialogs/SpeciesDetailDialog';
import { AddDiaryDialog } from '../dialogs/AddDiaryDialog';
import { ShareSummaryDialog } from '../dialogs/ShareSummaryDialog';

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

  // 弹窗状态
  @State showAddPlant: boolean = false;
  @State editingPlant: PlantModel | null = null;

  @State showPlantDetail: boolean = false;
  @State selectedPlant: PlantModel | null = null;

  @State showSpeciesDetail: boolean = false;
  @State selectedSpecies: SpeciesModel | null = null;

  @State showAddDiary: boolean = false;
  @State diaryPlantId: string = '';

  @State showShareSummary: boolean = false;

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
    // 更新当前选中的植物引用
    this.selectedPlant = StorageService.getInstance().getPlantById(plant.id);
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

  // ================= 花盆增删改 =================

  private handleSavePlant(plant: PlantModel): void {
    StorageService.getInstance().savePlant(plant);
    this.refreshData();
    this.showAddPlant = false;
    this.editingPlant = null;
  }

  private handleDeletePlant(plantId: string): void {
    StorageService.getInstance().deletePlant(plantId);
    this.refreshData();
    this.showPlantDetail = false;
    this.selectedPlant = null;
  }

  // ================= 百科导入花园 =================

  private handleSpeciesAddToGarden(sp: SpeciesModel): void {
    const today = DateUtil.formatDate();
    const newPlant: PlantModel = {
      id: `plt_${Date.now()}`,
      speciesId: sp.id,
      name: sp.name,
      nickname: `新收的${sp.name}`,
      location: '阳台散光区',
      potSize: '中盆(18cm)',
      icon: sp.icon,
      acquireDate: today,
      waterInterval: sp.suggestWaterDays,
      fertilizeInterval: sp.suggestFertilizeDays,
      lastWaterDate: today,
      lastFertilizeDate: today,
      healthStatus: 'thriving',
      notes: `从百花图鉴收录。《${sp.name}》花语：「${sp.flowerLanguage}」`,
      isFavorite: false
    };
    StorageService.getInstance().savePlant(newPlant);
    this.refreshData();
    this.showSpeciesDetail = false;
    // 切换到花园 Tab 提示查看
    this.currentTabIndex = 1;
    this.tabController.changeIndex(1);
  }

  // ================= 日记管理 =================

  private handleSaveDiary(diary: DiaryModel): void {
    StorageService.getInstance().addDiary(diary);
    this.refreshData();
    this.showAddDiary = false;
    this.diaryPlantId = '';
  }

  private handleDeleteDiary(diaryId: string): void {
    StorageService.getInstance().deleteDiary(diaryId);
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
            onOpenAddPlant: () => {
              this.editingPlant = null;
              this.showAddPlant = true;
            },
            onOpenAddDiary: () => {
              this.diaryPlantId = '';
              this.showAddDiary = true;
            },
            onOpenShareSummary: () => {
              this.showShareSummary = true;
            },
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
            onSelectPlant: (p: PlantModel) => {
              this.selectedPlant = p;
              this.showPlantDetail = true;
            },
            onOpenAddPlant: () => {
              this.editingPlant = null;
              this.showAddPlant = true;
            },
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
            speciesList: this.speciesList,
            onSelectSpecies: (sp: SpeciesModel) => {
              this.selectedSpecies = sp;
              this.showSpeciesDetail = true;
            },
            onQuickAddToGarden: (sp: SpeciesModel) => {
              this.handleSpeciesAddToGarden(sp);
            }
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
            onOpenAddDiary: () => {
              this.diaryPlantId = '';
              this.showAddDiary = true;
            },
            onDeleteDiary: (id: string) => {
              this.handleDeleteDiary(id);
            },
            onResetData: () => {
              StorageService.getInstance().resetToSampleData();
              this.refreshData();
            },
            onExportData: () => {
              // 打开数据分享
              this.showShareSummary = true;
            },
            onImportData: (jsonStr: string) => {
              const ok = StorageService.getInstance().importDataFromJson(jsonStr);
              if (ok) {
                this.refreshData();
              }
            },
            onOpenShareSummary: () => {
              this.showShareSummary = true;
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

      // ================= 全局弹窗层 =================

      // 1. 添加/编辑植物弹窗
      if (this.showAddPlant) {
        AddPlantDialog({
          isDark: this.isDark,
          speciesList: this.speciesList,
          editingPlant: this.editingPlant,
          onSave: (p: PlantModel) => {
            this.handleSavePlant(p);
          },
          onClose: () => {
            this.showAddPlant = false;
            this.editingPlant = null;
          }
        })
      }

      // 2. 植物深度详情弹窗
      if (this.showPlantDetail && this.selectedPlant) {
        PlantDetailDialog({
          isDark: this.isDark,
          plant: this.selectedPlant,
          careLogs: this.careLogs,
          diaries: this.diaries,
          onClose: () => {
            this.showPlantDetail = false;
            this.selectedPlant = null;
          },
          onEdit: (p: PlantModel) => {
            this.showPlantDetail = false;
            this.editingPlant = p;
            this.showAddPlant = true;
          },
          onDelete: (pId: string) => {
            this.handleDeletePlant(pId);
          },
          onCareAction: (p: PlantModel, act: string, name: string) => {
            this.handlePlantCareAction(p, act, name);
          },
          onAddDiary: (p: PlantModel) => {
            this.showPlantDetail = false;
            this.diaryPlantId = p.id;
            this.showAddDiary = true;
          }
        })
      }

      // 3. 花种百科详情弹窗
      if (this.showSpeciesDetail && this.selectedSpecies) {
        SpeciesDetailDialog({
          isDark: this.isDark,
          species: this.selectedSpecies,
          onClose: () => {
            this.showSpeciesDetail = false;
            this.selectedSpecies = null;
          },
          onAddToGarden: (sp: SpeciesModel) => {
            this.handleSpeciesAddToGarden(sp);
          }
        })
      }

      // 4. 新增日记弹窗
      if (this.showAddDiary) {
        AddDiaryDialog({
          isDark: this.isDark,
          plants: this.plants,
          defaultPlantId: this.diaryPlantId,
          onSave: (d: DiaryModel) => {
            this.handleSaveDiary(d);
          },
          onClose: () => {
            this.showAddDiary = false;
            this.diaryPlantId = '';
          }
        })
      }

      // 5. 养护回顾卡片弹窗
      if (this.showShareSummary) {
        ShareSummaryDialog({
          isDark: this.isDark,
          plants: this.plants,
          careLogs: this.careLogs,
          diaries: this.diaries,
          streakDays: this.streakDays,
          onClose: () => {
            this.showShareSummary = false;
          }
        })
      }
    }
    .width('100%')
    .height('100%')
  }
}