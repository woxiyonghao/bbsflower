import { PlantModel } from '../common/models/PlantModel';
import { CareLogModel } from '../common/models/CareLogModel';
import { DiaryModel } from '../common/models/DiaryModel';
import { DateUtil } from '../common/utils/DateUtil';

@Component
export struct ShareSummaryDialog {
  @Prop isDark: boolean = false;
  @Prop plants: PlantModel[] = [];
  @Prop careLogs: CareLogModel[] = [];
  @Prop diaries: DiaryModel[] = [];
  @Prop streakDays: number = 0;
  onClose?: () => void;

  private getFavoritePlantName(): string {
    if (this.plants.length === 0) {
      return '万物生辉';
    }
    const fav = this.plants.find(p => p.isFavorite);
    return fav ? fav.nickname : this.plants[0].nickname;
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      // 遮罩
      Rect()
        .width('100%')
        .height('100%')
        .fill(this.isDark ? 'rgba(0, 0, 0, 0.70)' : 'rgba(20, 15, 30, 0.45)')
        .onClick(() => {
          if (this.onClose) {
            this.onClose();
          }
        })

      Column() {
        // 卡片内容（生成图样貌）
        Column({ space: 16 }) {
          // 顶部小徽标
          Row({ space: 8 }) {
            Text('🌸')
              .fontSize(22)
            Column({ space: 2 }) {
              Text('琉璃花语 · 绿意时光纪念卡')
                .fontSize(14)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.isDark ? '#D4B87E' : '#C9A96E')
              Text(`${DateUtil.formatDate()} · 本地单机守护`)
                .fontSize(10)
                .fontColor(this.isDark ? '#736F90' : '#8E8AA3')
            }
            .alignItems(HorizontalAlign.Start)

            Blank()

            Button('✕')
              .fontSize(16)
              .fontColor(this.isDark ? '#A29DC0' : '#8E8AA3')
              .backgroundColor('transparent')
              .onClick(() => {
                if (this.onClose) {
                  this.onClose();
                }
              })
          }
          .width('100%')

          // 核心数字矩阵
          GridRow({ columns: 2, gutter: 10 }) {
            // 连续养护
            GridCol() {
              Column({ space: 4 }) {
                Text(`${this.streakDays} 天`)
                  .fontSize(24)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.isDark ? '#D4B87E' : '#A8874A')
                Text('连续养护天数')
                  .fontSize(11)
                  .fontColor(this.isDark ? '#A29DC0' : '#6B6780')
              }
              .padding(12)
              .borderRadius(14)
              .backgroundColor(this.isDark ? 'rgba(212, 184, 126, 0.12)' : '#FDF4E5')
              .width('100%')
            }

            // 花园藏株
            GridCol() {
              Column({ space: 4 }) {
                Text(`${this.plants.length} 株`)
                  .fontSize(24)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.isDark ? '#8EE0D0' : '#388E6D')
                Text('花园常伴植物')
                  .fontSize(11)
                  .fontColor(this.isDark ? '#A29DC0' : '#6B6780')
              }
              .padding(12)
              .borderRadius(14)
              .backgroundColor(this.isDark ? 'rgba(110, 220, 200, 0.12)' : '#E8F7F2')
              .width('100%')
            }

            // 累计打卡
            GridCol() {
              Column({ space: 4 }) {
                Text(`${this.careLogs.length} 次`)
                  .fontSize(24)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.isDark ? '#9CC8F0' : '#3577B8')
                Text('甘霖滋养打卡')
                  .fontSize(11)
                  .fontColor(this.isDark ? '#A29DC0' : '#6B6780')
              }
              .padding(12)
              .borderRadius(14)
              .backgroundColor(this.isDark ? 'rgba(120, 180, 240, 0.12)' : '#EBF4FC')
              .width('100%')
            }

            // 观察手记
            GridCol() {
              Column({ space: 4 }) {
                Text(`${this.diaries.length} 篇`)
                  .fontSize(24)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.isDark ? '#F0B8D0' : '#B3587E')
                Text('草木成长手记')
                  .fontSize(11)
                  .fontColor(this.isDark ? '#A29DC0' : '#6B6780')
              }
              .padding(12)
              .borderRadius(14)
              .backgroundColor(this.isDark ? 'rgba(232, 160, 191, 0.12)' : '#FDF0F5')
              .width('100%')
            }
          }
          .width('100%')

          // 最常照料
          Row({ space: 8 }) {
            Text('🪴')
              .fontSize(16)
            Text(`心尖挚爱：「${this.getFavoritePlantName()}」`)
              .fontSize(13)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.isDark ? '#F2EFF9' : '#2D2A3F')
          }
          .width('100%')
          .padding(12)
          .borderRadius(12)
          .backgroundColor(this.isDark ? 'rgba(255, 255, 255, 0.06)' : 'rgba(0, 0, 0, 0.03)')

          // 寄语
          Text('“一勺清澈水，半窗柔和风。草木无言，却默默以新绿回馈你所有的温柔以待。”')
            .fontSize(12)
            .fontStyle(FontStyle.Italic)
            .fontColor(this.isDark ? '#A29DC0' : '#6B6780')
            .lineHeight(18)
            .textAlign(TextAlign.Center)
            .width('95%')
            .margin({ top: 4 })
        }
        .width('90%')
        .padding(22)
        .borderRadius(26)
        .backgroundColor(this.isDark ? '#1C162E' : '#FFFFFF')
        .borderWidth(1)
        .borderColor(this.isDark ? 'rgba(255, 255, 255, 0.16)' : 'rgba(255, 255, 255, 0.85)')
        .shadow({
          radius: 30,
          color: this.isDark ? 'rgba(0,0,0,0.6)' : 'rgba(90, 70, 140, 0.16)',
          offsetY: 10
        })
      }
    }
    .width('100%')
    .height('100%')
  }
}
