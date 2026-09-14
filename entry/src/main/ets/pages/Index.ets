import common from '@ohos.app.ability.common';
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
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
  @State showPrivacyDialog: boolean = false;

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

    // 2. 检查隐私协议合规签署状态
    this.showPrivacyDialog = !StorageService.getInstance().getHasAgreedPrivacy();

    // 3. 初始化主题
    ThemeManager.getInstance().init();
    this.themeMode = ThemeManager.getInstance().getThemeMode();
    this.updateDarkModeState();

    // 4. 读取并刷新数据
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

      // 4. 首次冷启动隐私协议合规弹窗
      if (this.showPrivacyDialog) {
        Stack() {
          // 蒙层
          Column()
            .width('100%')
            .height('100%')
            .backgroundColor('rgba(0, 0, 0, 0.65)')
            .backdropBlur(15)

          // 弹窗卡片
          Column({ space: 16 }) {
            // 头部
            Column({ space: 6 }) {
              Row({ space: 8 }) {
                Text('🌸')
                  .fontSize(28)
                Text('花伴录服务与隐私指引')
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.isDark ? '#F5E6C8' : '#2D283E')
              }
              .alignItems(VerticalAlign.Center)

              Text('纯单机离线 · 零云端上传 · 保护您的私密空间')
                .fontSize(12)
                .fontColor(this.isDark ? '#D4B87E' : '#A8874A')
                .fontWeight(FontWeight.Medium)
            }
            .alignItems(HorizontalAlign.Center)
            .width('100%')

            // 正文说明
            Column({ space: 10 }) {
              Text('欢迎使用「花伴录」！为了向您提供植物图鉴、养护打卡与日记记录功能，请您充分阅读并知悉以下说明：')
                .fontSize(13)
                .fontColor(this.isDark ? '#DDD8EC' : '#4E4A62')
                .lineHeight(20)

              Column({ space: 6 }) {
                Row({ space: 6 }) {
                  Text('•')
                    .fontSize(13)
                    .fontColor(this.isDark ? '#D4B87E' : '#A8874A')
                  Text('单机运行：本应用不申请外部网络权限，不收集设备识别码与个人账号。')
                    .fontSize(12)
                    .fontColor(this.isDark ? '#BBB5D4' : '#646079')
                    .layoutWeight(1)
                    .lineHeight(18)
                }

                Row({ space: 6 }) {
                  Text('•')
                    .fontSize(13)
                    .fontColor(this.isDark ? '#D4B87E' : '#A8874A')
                  Text('沙盒存储：您的养护数据与日记均保存在本机沙盒，可自主导出备份。')
                    .fontSize(12)
                    .fontColor(this.isDark ? '#BBB5D4' : '#646079')
                    .layoutWeight(1)
                    .lineHeight(18)
                }

                Row({ space: 6 }) {
                  Text('•')
                    .fontSize(13)
                    .fontColor(this.isDark ? '#D4B87E' : '#A8874A')
                  Text('相册权限：仅在您主动上传植物或日记照片时，按需申请只读相册授权。')
                    .fontSize(12)
                    .fontColor(this.isDark ? '#BBB5D4' : '#646079')
                    .layoutWeight(1)
                    .lineHeight(18)
                }
              }
              .width('100%')
              .padding(10)
              .backgroundColor(this.isDark ? 'rgba(255, 255, 255, 0.05)' : 'rgba(168, 135, 74, 0.08)')
              .borderRadius(12)

              Row() {
                Text('点击阅读完整的')
                  .fontSize(12)
                  .fontColor(this.isDark ? '#A29DC0' : '#77728D')
                Text('《隐私政策与用户协议》')
                  .fontSize(12)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.isDark ? '#E5C483' : '#8A5D18')
                  .decoration({ type: TextDecorationType.Underline, color: this.isDark ? '#E5C483' : '#8A5D18' })
                  .onClick(() => {
                    router.pushUrl({ url: 'pages/PrivacyPolicyPage' });
                  })
              }
              .width('100%')
              .justifyContent(FlexAlign.Center)
              .padding({ top: 4 })
            }
            .width('100%')

            // 底部操作按钮
            Row({ space: 12 }) {
              Button('不同意并退出')
                .fontSize(14)
                .fontColor(this.isDark ? '#AAA5C0' : '#7D7992')
                .backgroundColor(this.isDark ? 'rgba(255, 255, 255, 0.08)' : 'rgba(0, 0, 0, 0.06)')
                .borderRadius(20)
                .height(42)
                .layoutWeight(1)
                .onClick(() => {
                  try {
                    const ctx = this.getUIContext()?.getHostContext() as common.UIAbilityContext;
                    if (ctx && ctx.terminateSelf) {
                      ctx.terminateSelf();
                    } else {
                      promptAction.showToast({ message: '请同意隐私协议后方可使用本应用' });
                    }
                  } catch (e) {
                    promptAction.showToast({ message: '请同意隐私协议后方可使用本应用' });
                  }
                })

              Button('同意并开启')
                .fontSize(14)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.isDark ? '#1C1508' : '#FFFFFF')
                .backgroundColor(this.isDark ? '#D4B87E' : '#9E7836')
                .borderRadius(20)
                .height(42)
                .layoutWeight(1.2)
                .shadow({ radius: 8, color: this.isDark ? 'rgba(212, 184, 126, 0.35)' : 'rgba(158, 120, 54, 0.35)', offsetY: 2 })
                .onClick(() => {
                  StorageService.getInstance().setHasAgreedPrivacy(true);
                  this.showPrivacyDialog = false;
                  promptAction.showToast({ message: '欢迎踏入花伴雅境' });
                })
            }
            .width('100%')
            .padding({ top: 4 })
          }
          .width('88%')
          .padding(22)
          .borderRadius(24)
          .backgroundColor(this.isDark ? '#252038' : '#FAF8F5')
          .border({ width: 1, color: this.isDark ? 'rgba(212, 184, 126, 0.3)' : 'rgba(168, 135, 74, 0.25)' })
          .shadow({ radius: 25, color: 'rgba(0, 0, 0, 0.35)', offsetY: 8 })
          .align(Alignment.Center)
        }
        .width('100%')
        .height('100%')
        .alignContent(Alignment.Center)
      }
    }
    .width('100%')
    .height('100%')
  }

  pageTransition() {
    // 离开首页前往二级页面：向左滑出避让
    PageTransitionExit({ type: RouteType.Push, duration: 280, curve: Curve.EaseOut })
      .slide(SlideEffect.Left)
      .opacity(0)
    // 从二级页面返回首页：从左边滑入恢复
    PageTransitionEnter({ type: RouteType.Pop, duration: 280, curve: Curve.EaseOut })
      .slide(SlideEffect.Left)
      .opacity(0)
  }
}