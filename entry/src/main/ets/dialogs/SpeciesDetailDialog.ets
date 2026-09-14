import { SpeciesModel } from '../common/models/SpeciesModel';
import { StatBadge } from '../common/components/StatBadge';

@Component
export struct SpeciesDetailDialog {
  @Prop isDark: boolean = false;
  @Prop species: SpeciesModel | null = null;
  onClose?: () => void;
  onAddToGarden?: (species: SpeciesModel) => void;

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

      if (this.species) {
        Column() {
          // 头部
          Row() {
            Row({ space: 10 }) {
              Text(this.species.icon)
                .fontSize(32)
              Column({ space: 4 }) {
                Row({ space: 6 }) {
                  Text(this.species.name)
                    .fontSize(19)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(this.isDark ? '#F2EFF9' : '#2D2A3F')
                  StatBadge({
                    text: this.species.difficultyName,
                    colorScheme: this.species.difficulty === 'easy' ? 'green' : (this.species.difficulty === 'medium' ? 'gold' : 'petal'),
                    isDark: this.isDark
                  })
                }
                Text(`${this.species.latinName} · ${this.species.family}`)
                  .fontSize(11)
                  .fontColor(this.isDark ? '#A29DC0' : '#8E8AA3')
              }
              .alignItems(HorizontalAlign.Start)
            }

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
          .padding({ bottom: 12 })

          Scroll() {
            Column({ space: 14 }) {
              // 1. 花语横幅
              Row({ space: 8 }) {
                Text('💌')
                  .fontSize(16)
                Text(`花语：「${this.species.flowerLanguage}」`)
                  .fontSize(13)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.isDark ? '#E8A0BF' : '#9B4A6E')
              }
              .width('100%')
              .padding(10)
              .borderRadius(12)
              .backgroundColor(this.isDark ? 'rgba(232, 160, 191, 0.12)' : '#FDF2F7')

              // 2. 简述
              Text(this.species.description)
                .fontSize(12.5)
                .fontColor(this.isDark ? '#DCD8EA' : '#4E4A62')
                .lineHeight(19)
                .width('100%')

              // 3. 四大核心养护要素
              Column({ space: 8 }) {
                Text('养护核心要素')
                  .fontSize(12)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.isDark ? '#D4B87E' : '#A8874A')

                GridRow({ columns: 2, gutter: 8 }) {
                  // 光照
                  GridCol() {
                    Column({ space: 4 }) {
                      Text('☀️ 光照需求')
                        .fontSize(11)
                        .fontWeight(FontWeight.Medium)
                        .fontColor(this.isDark ? '#D4B87E' : '#8B6914')
                      Text(this.species.light)
                        .fontSize(11.5)
                        .fontColor(this.isDark ? '#DCD8EA' : '#2D2A3F')
                        .lineHeight(16)
                    }
                    .padding(8)
                    .borderRadius(10)
                    .backgroundColor(this.isDark ? 'rgba(212, 184, 126, 0.10)' : '#FDF7EB')
                    .width('100%')
                    .alignItems(HorizontalAlign.Start)
                  }

                  // 水分
                  GridCol() {
                    Column({ space: 4 }) {
                      Text(`💧 浇水周期 (~${this.species.suggestWaterDays}天)`)
                        .fontSize(11)
                        .fontWeight(FontWeight.Medium)
                        .fontColor(this.isDark ? '#9CC8F0' : '#2B6CB0')
                      Text(this.species.waterGuide)
                        .fontSize(11.5)
                        .fontColor(this.isDark ? '#DCD8EA' : '#2D2A3F')
                        .lineHeight(16)
                    }
                    .padding(8)
                    .borderRadius(10)
                    .backgroundColor(this.isDark ? 'rgba(120, 180, 240, 0.10)' : '#F0F6FD')
                    .width('100%')
                    .alignItems(HorizontalAlign.Start)
                  }

                  // 温度
                  GridCol() {
                    Column({ space: 4 }) {
                      Text('🌡️ 适宜温度')
                        .fontSize(11)
                        .fontWeight(FontWeight.Medium)
                        .fontColor(this.isDark ? '#8EE0D0' : '#234E52')
                      Text(this.species.temperature)
                        .fontSize(11.5)
                        .fontColor(this.isDark ? '#DCD8EA' : '#2D2A3F')
                        .lineHeight(16)
                    }
                    .padding(8)
                    .borderRadius(10)
                    .backgroundColor(this.isDark ? 'rgba(110, 220, 200, 0.10)' : '#EFFBF7')
                    .width('100%')
                    .alignItems(HorizontalAlign.Start)
                  }

                  // 湿度
                  GridCol() {
                    Column({ space: 4 }) {
                      Text('🌫️ 空气湿度')
                        .fontSize(11)
                        .fontWeight(FontWeight.Medium)
                        .fontColor(this.isDark ? '#C4B4EE' : '#5E4A8C')
                      Text(this.species.humidity)
                        .fontSize(11.5)
                        .fontColor(this.isDark ? '#DCD8EA' : '#2D2A3F')
                        .lineHeight(16)
                    }
                    .padding(8)
                    .borderRadius(10)
                    .backgroundColor(this.isDark ? 'rgba(166, 150, 208, 0.10)' : '#F5F1FB')
                    .width('100%')
                    .alignItems(HorizontalAlign.Start)
                  }
                }
                .width('100%')
              }
              .alignItems(HorizontalAlign.Start)
              .width('100%')

              // 4. 土壤与施肥
              Column({ space: 4 }) {
                Text('🪴 土壤与施肥建议')
                  .fontSize(12)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.isDark ? '#A29DC0' : '#6B6780')
                Text(this.species.soilGuide)
                  .fontSize(12)
                  .fontColor(this.isDark ? '#DCD8EA' : '#4E4A62')
                  .lineHeight(18)
              }
              .alignItems(HorizontalAlign.Start)
              .width('100%')

              // 5. 修剪与繁殖
              Column({ space: 4 }) {
                Text('✂️ 修剪与繁殖诀窍')
                  .fontSize(12)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.isDark ? '#A29DC0' : '#6B6780')
                Text(this.species.pruneGuide)
                  .fontSize(12)
                  .fontColor(this.isDark ? '#DCD8EA' : '#4E4A62')
                  .lineHeight(18)
              }
              .alignItems(HorizontalAlign.Start)
              .width('100%')

              // 6. 常见病害诊治
              Column({ space: 4 }) {
                Text('🛡️ 常见病害及应对')
                  .fontSize(12)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.isDark ? '#F0B8D0' : '#B3587E')
                Text(this.species.troubleshooting)
                  .fontSize(12)
                  .fontColor(this.isDark ? '#DCD8EA' : '#4E4A62')
                  .lineHeight(18)
              }
              .alignItems(HorizontalAlign.Start)
              .width('100%')
            }
          }
          .constraintSize({ maxHeight: 380 })
          .scrollBar(BarState.Off)

          // 底部操作
          Row({ space: 12 }) {
            Button('关闭')
              .layoutWeight(1)
              .height(42)
              .fontSize(14)
              .fontColor(this.isDark ? '#A29DC0' : '#6B6780')
              .backgroundColor(this.isDark ? 'rgba(255, 255, 255, 0.08)' : 'rgba(0, 0, 0, 0.05)')
              .borderRadius(14)
              .onClick(() => {
                if (this.onClose) {
                  this.onClose();
                }
              })

            Button('🪴 一键收进我的花园')
              .layoutWeight(1.4)
              .height(42)
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
              .backgroundColor(this.isDark ? '#B8985E' : '#C9A96E')
              .borderRadius(14)
              .onClick(() => {
                if (this.onAddToGarden && this.species) {
                  this.onAddToGarden(this.species);
                }
              })
          }
          .width('100%')
          .margin({ top: 16 })
        }
        .width('92%')
        .padding(20)
        .borderRadius(24)
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
