/**
 * 液态玻璃拟态卡片容器组件
 */
@Component
export struct GlassCard {
  @Prop isDark: boolean = false;
  @Prop radius: number = 20;
  @Prop paddingVal: number = 16;
  @Prop borderWidthVal: number = 1;
  @Prop customBg: string = '';
  @BuilderParam content: () => void = this.defaultContent;

  @Builder defaultContent() {}

  build() {
    Column() {
      this.content()
    }
    .width('100%')
    .padding(this.paddingVal)
    .borderRadius(this.radius)
    .backgroundColor(
      this.customBg.length > 0
        ? this.customBg
        : (this.isDark ? 'rgba(32, 26, 48, 0.78)' : 'rgba(255, 255, 255, 0.76)')
    )
    .borderWidth(this.borderWidthVal)
    .borderColor(this.isDark ? 'rgba(255, 255, 255, 0.14)' : 'rgba(255, 255, 255, 0.85)')
    .shadow({
      radius: 16,
      color: this.isDark ? 'rgba(0, 0, 0, 0.45)' : 'rgba(100, 80, 140, 0.08)',
      offsetX: 0,
      offsetY: 6
    })
    .backdropBlur(25)
    .animation({ duration: 250, curve: Curve.EaseInOut })
  }
}
