/**
 * 空状态温润插画与提示组件
 */
@Component
export struct EmptyState {
  @Prop icon: string = '🌸';
  @Prop title: string = '花间暂无记录';
  @Prop desc: string = '一草一木皆有灵性，点击下方开始记录你的第一抹绿意吧。';
  @Prop buttonText: string = '';
  @Prop isDark: boolean = false;
  onButtonClick?: () => void;

  build() {
    Column({ space: 12 }) {
      Text(this.icon)
        .fontSize(48)
        .margin({ bottom: 4 })

      Text(this.title)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.isDark ? '#F2EFF9' : '#2D2A3F')

      Text(this.desc)
        .fontSize(13)
        .fontColor(this.isDark ? '#8E8AA3' : '#7C7791')
        .textAlign(TextAlign.Center)
        .width('80%')
        .lineHeight(20)

      if (this.buttonText.length > 0) {
        Button(this.buttonText)
          .fontSize(13)
          .fontColor('#FFFFFF')
          .fontWeight(FontWeight.Medium)
          .padding({ left: 20, right: 20, top: 10, bottom: 10 })
          .borderRadius(16)
          .backgroundColor(this.isDark ? '#B8985E' : '#C9A96E')
          .margin({ top: 8 })
          .onClick(() => {
            if (this.onButtonClick) {
              this.onButtonClick();
            }
          })
      }
    }
    .width('100%')
    .padding({ top: 40, bottom: 40, left: 20, right: 20 })
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
  }
}
