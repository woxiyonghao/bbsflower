/**
 * 标签徽章胶囊组件
 */
@Component
export struct StatBadge {
  @Prop text: string = '';
  @Prop icon: string = '';
  @Prop colorScheme: string = 'gold'; // gold, violet, green, petal, blue, gray
  @Prop isDark: boolean = false;

  private getBgColor(): string {
    if (this.isDark) {
      switch (this.colorScheme) {
        case 'gold': return 'rgba(212, 184, 126, 0.18)';
        case 'violet': return 'rgba(166, 150, 208, 0.18)';
        case 'green': return 'rgba(110, 220, 200, 0.18)';
        case 'petal': return 'rgba(232, 160, 191, 0.18)';
        case 'blue': return 'rgba(120, 180, 240, 0.18)';
        default: return 'rgba(255, 255, 255, 0.10)';
      }
    } else {
      switch (this.colorScheme) {
        case 'gold': return '#FDF2E2';
        case 'violet': return '#F2EDFA';
        case 'green': return '#E8F7F2';
        case 'petal': return '#FDF0F5';
        case 'blue': return '#EBF4FC';
        default: return '#F0EFF4';
      }
    }
  }

  private getTextColor(): string {
    if (this.isDark) {
      switch (this.colorScheme) {
        case 'gold': return '#E4CC94';
        case 'violet': return '#C4B4EE';
        case 'green': return '#8EE0D0';
        case 'petal': return '#F0B8D0';
        case 'blue': return '#9CC8F0';
        default: return '#C5BFD6';
      }
    } else {
      switch (this.colorScheme) {
        case 'gold': return '#A8874A';
        case 'violet': return '#6B5899';
        case 'green': return '#388E6D';
        case 'petal': return '#B3587E';
        case 'blue': return '#3577B8';
        default: return '#666278';
      }
    }
  }

  build() {
    Row({ space: 4 }) {
      if (this.icon.length > 0) {
        Text(this.icon)
          .fontSize(11)
      }
      Text(this.text)
        .fontSize(11)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.getTextColor())
    }
    .padding({ left: 8, right: 8, top: 4, bottom: 4 })
    .borderRadius(8)
    .backgroundColor(this.getBgColor())
  }
}
