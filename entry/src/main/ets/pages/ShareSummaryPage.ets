import router from '@ohos.router';
import { PlantModel } from '../common/models/PlantModel';
import { CareLogModel } from '../common/models/CareLogModel';
import { DiaryModel } from '../common/models/DiaryModel';
import { StorageService } from '../common/database/StorageService';
import { ThemeManager } from '../theme/ThemeManager';
import { DateUtil } from '../common/utils/DateUtil';
import { PlantIcon } from '../common/components/PlantIcon';
import { GlassCard } from '../common/components/GlassCard';

@Entry
@Component
struct ShareSummaryPage {
  @State isDark: boolean = false;
  @State plants: PlantModel[] = [];
  @State careLogs: CareLogModel[] = [];
  @State diaries: DiaryModel[] = [];
  @State streakDays: number = 0;
  @State showExportJson: boolean = false;
  @State exportJsonString: string = '';

  aboutToAppear(): void {
    this.isDark = ThemeManager.getInstance().isDark();
    const storage = StorageService.getInstance();
    this.plants = storage.getPlants();
    this.careLogs = storage.getCareLogs();
    this.diaries = storage.getDiaries();
    this.streakDays = DateUtil.calculateStreak(this.careLogs.map(l => l.date));
  }

  private getFavoritePlant(): PlantModel | null {
    if (this.plants.length === 0) {
      return null;
    }
    const fav = this.plants.find(p => p.isFavorite);
    return fav ? fav : this.plants[0];
  }

  private handleExportData(): void {
    this.exportJsonString = StorageService.getInstance().exportDataAsJson();
    this.showExportJson = true;
  }

  build() {
    Column() {
      // 1. 顶部 Navigation Header
      Row() {
        Button('❮ 返回')
          .fontSize(14)
          .fontColor(this.isDark ? '#D4B87E' : '#A8874A')
          .backgroundColor('transparent')
          .onClick(() => {
            router.back();
          })

        Blank()

        Text('养护时光回顾')
          .fontSize(17)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.isDark ? '#F2EFF9' : '#1F1B33')

        Blank()

        Button('📦 导出JSON')
          .fontSize(13)
          .fontColor(this.isDark ? '#9CC8F0' : '#2B6CB0')
          .backgroundColor('transparent')
          .onClick(() => {
            this.handleExportData();
          })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
      .backgroundColor(this.isDark ? '#140E24' : '#F9F5EE')

      Scroll() {
        Column({ space: 16 }) {
          // 2. 精美时光回顾主卡片
          GlassCard({ isDark: this.isDark, radius: 26, paddingVal: 22 }) {
            Column({ space: 18 }) {
              // 头部标语
              Row({ space: 10 }) {
                Text('🌸').fontSize(26)
                Column({ space: 2 }) {
                  Text('琉璃花语 · 绿意时光手记')
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(this.isDark ? '#D4B87E' : '#C9A96E')
                  Text(`${DateUtil.formatDate()} · 芳华尽在方寸之间`)
                    .fontSize(11)
                    .fontColor(this.isDark ? '#736F90' : '#8E8AA3')
                }
                .alignItems(HorizontalAlign.Start)
              }
              .width('100%')

              // 核心四格指标
              GridRow({ columns: 2, gutter: 12 }) {
                // 连续打卡
                GridCol() {
                  Column({ space: 4 }) {
                    Text(`${this.streakDays} 天`)
                      .fontSize(26)
                      .fontWeight(FontWeight.Bold)
                      .fontColor(this.isDark ? '#D4B87E' : '#A8874A')
                    Text('连续长青坚守')
                      .fontSize(11.5)
                      .fontColor(this.isDark ? '#A29DC0' : '#6B6780')
                  }
                  .alignItems(HorizontalAlign.Start)
                  .padding(14)
                  .borderRadius(16)
                  .backgroundColor(this.isDark ? 'rgba(212, 184, 126, 0.12)' : '#FBF7EE')
                }

                // 在养花草
                GridCol() {
                  Column({ space: 4 }) {
                    Text(`${this.plants.length} 株`)
                      .fontSize(26)
                      .fontWeight(FontWeight.Bold)
                      .fontColor(this.isDark ? '#6BB89C' : '#3E8C6C')
                    Text('花园常伴植物')
                      .fontSize(11.5)
                      .fontColor(this.isDark ? '#A29DC0' : '#6B6780')
                  }
                  .alignItems(HorizontalAlign.Start)
                  .padding(14)
                  .borderRadius(16)
                  .backgroundColor(this.isDark ? 'rgba(62, 140, 108, 0.12)' : '#EDF6F2')
                }

                // 累计浇灌打卡
                GridCol() {
                  Column({ space: 4 }) {
                    Text(`${this.careLogs.length} 次`)
                      .fontSize(26)
                      .fontWeight(FontWeight.Bold)
                      .fontColor(this.isDark ? '#7AAEE0' : '#3B7EBD')
                    Text('甘霖浇灌打卡')
                      .fontSize(11.5)
                      .fontColor(this.isDark ? '#A29DC0' : '#6B6780')
                  }
                  .alignItems(HorizontalAlign.Start)
                  .padding(14)
                  .borderRadius(16)
                  .backgroundColor(this.isDark ? 'rgba(59, 126, 189, 0.12)' : '#EEF4FA')
                }

                // 成长手记
                GridCol() {
                  Column({ space: 4 }) {
                    Text(`${this.diaries.length} 篇`)
                      .fontSize(26)
                      .fontWeight(FontWeight.Bold)
                      .fontColor(this.isDark ? '#E592A4' : '#C75D74')
                    Text('草木成长手记')
                      .fontSize(11.5)
                      .fontColor(this.isDark ? '#A29DC0' : '#6B6780')
                  }
                  .alignItems(HorizontalAlign.Start)
                  .padding(14)
                  .borderRadius(16)
                  .backgroundColor(this.isDark ? 'rgba(199, 93, 116, 0.12)' : '#FAEFF2')
                }
              }
              .width('100%')

              // 心尖挚爱花草
              if (this.getFavoritePlant()) {
                Row({ space: 12 }) {
                  PlantIcon({
                    plantName: this.getFavoritePlant()?.name || '绿萝',
                    sizeVal: 52,
                    isDark: this.isDark
                  })

                  Column({ space: 4 }) {
                    Text('心尖挚爱花草')
                      .fontSize(11)
                      .fontColor(this.isDark ? '#D4B87E' : '#C9A96E')
                    Text(`「${this.getFavoritePlant()?.nickname}」`)
                      .fontSize(16)
                      .fontWeight(FontWeight.Bold)
                      .fontColor(this.isDark ? '#F2EFF9' : '#2D2A3F')
                    Text(`位置: ${this.getFavoritePlant()?.location} · 状态良好`)
                      .fontSize(11)
                      .fontColor(this.isDark ? '#A29DC0' : '#8E8AA3')
                  }
                  .alignItems(HorizontalAlign.Start)
                  .layoutWeight(1)
                }
                .width('100%')
                .padding(14)
                .borderRadius(16)
                .backgroundColor(this.isDark ? 'rgba(255, 255, 255, 0.05)' : 'rgba(0, 0, 0, 0.03)')
              }

              // 诗意箴言
              Text('“一勺清水润泥土，半缕暖阳度初晨。草木无言，却因你的坚守而在岁月里绽放温柔。”')
                .fontSize(13)
                .fontStyle(FontStyle.Italic)
                .fontColor(this.isDark ? '#A29DC0' : '#6B6780')
                .lineHeight(21)
                .textAlign(TextAlign.Center)
                .width('95%')
            }
            .width('100%')
          }

          // 3. 导出 JSON 数据展示弹窗
          if (this.showExportJson) {
            GlassCard({ isDark: this.isDark, radius: 20, paddingVal: 16 }) {
              Column({ space: 10 }) {
                Row() {
                  Text('📦 本地全量数据 JSON 备份')
                    .fontSize(14)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(this.isDark ? '#F2EFF9' : '#2D2A3F')

                  Blank()

                  Button('关闭')
                    .fontSize(12)
                    .fontColor(this.isDark ? '#A29DC0' : '#8E8AA3')
                    .backgroundColor('transparent')
                    .onClick(() => {
                      this.showExportJson = false;
                    })
                }
                .width('100%')

                TextArea({ text: this.exportJsonString })
                  .fontSize(11)
                  .height(160)
                  .backgroundColor(this.isDark ? 'rgba(255, 255, 255, 0.06)' : 'rgba(0, 0, 0, 0.04)')
                  .fontColor(this.isDark ? '#F2EFF9' : '#2D2A3F')
                  .borderRadius(10)
              }
              .width('100%')
            }
          }
        }
        .width('100%')
        .justifyContent(FlexAlign.Start)
        .padding({ left: 16, right: 16, top: 12, bottom: 24 })
      }
      .layoutWeight(1)
      .align(Alignment.Top)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.isDark ? '#100D1C' : '#FAF6F0')
  }

  pageTransition() {
    PageTransitionEnter({ type: RouteType.Push, duration: 280, curve: Curve.EaseOut })
      .slide(SlideEffect.Left)
      .opacity(0.8)
    PageTransitionExit({ type: RouteType.Pop, duration: 240, curve: Curve.EaseIn })
      .slide(SlideEffect.Right)
      .opacity(0.8)
    PageTransitionEnter({ type: RouteType.Pop, duration: 240, curve: Curve.EaseOut })
      .slide(SlideEffect.Right)
      .opacity(0.8)
    PageTransitionExit({ type: RouteType.Push, duration: 280, curve: Curve.EaseIn })
      .slide(SlideEffect.Left)
      .opacity(0.8)
  }
}
