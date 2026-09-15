/**
 * 花卉精准视觉图标组件
 * 专为各名花定制专属花色渐变底板与特征标识
 */

export interface PlantVisualConfig {
  bgColorLight: string;
  bgColorDark: string;
  badgeSymbol: string;     // 植物专属核心形态符号
  subSymbol: string;       // 叶/花辅助特征
  textColorLight: string;
  textColorDark: string;
  borderColorLight: string;
  borderColorDark: string;
}

export class PlantIconProvider {
  /**
   * 获取每种花精准的视觉特征配置
   */
  public static getConfig(plantNameOrId: string): PlantVisualConfig {
    const key = plantNameOrId.toLowerCase();

    // 1. 绿萝：心形常绿水滴藤叶
    if (key.indexOf('绿萝') !== -1 || key.indexOf('lvluo') !== -1) {
      return {
        bgColorLight: '#E6F7ED',
        bgColorDark: 'rgba(40, 100, 70, 0.35)',
        badgeSymbol: '🌱',
        subSymbol: '💧',
        textColorLight: '#237844',
        textColorDark: '#73D197',
        borderColorLight: '#B7EB8F',
        borderColorDark: 'rgba(82, 196, 26, 0.3)'
      };
    }

    // 2. 虎皮兰：挺拔金边剑叶
    if (key.indexOf('虎皮兰') !== -1 || key.indexOf('hupilan') !== -1 || key.indexOf('虎尾') !== -1) {
      return {
        bgColorLight: '#FEF9E7',
        bgColorDark: 'rgba(120, 100, 30, 0.35)',
        badgeSymbol: '🪴',
        subSymbol: '⚡',
        textColorLight: '#AD8B00',
        textColorDark: '#FADB14',
        borderColorLight: '#FFE58F',
        borderColorDark: 'rgba(250, 219, 20, 0.3)'
      };
    }

    // 3. 龟背竹：开背羽裂龟甲阔叶
    if (key.indexOf('龟背') !== -1 || key.indexOf('guibei') !== -1) {
      return {
        bgColorLight: '#E8F6F0',
        bgColorDark: 'rgba(30, 90, 65, 0.35)',
        badgeSymbol: '🍃',
        subSymbol: '✨',
        textColorLight: '#1B6A4C',
        textColorDark: '#5CBA93',
        borderColorLight: '#99D9BC',
        borderColorDark: 'rgba(56, 158, 117, 0.3)'
      };
    }

    // 4. 蝴蝶兰：紫蝶翻飞洋兰花冠
    if (key.indexOf('蝴蝶兰') !== -1 || key.indexOf('hudie') !== -1 || key.indexOf('兰') !== -1) {
      return {
        bgColorLight: '#F7EDFC',
        bgColorDark: 'rgba(90, 50, 120, 0.35)',
        badgeSymbol: '🌸',
        subSymbol: '🦋',
        textColorLight: '#722ED1',
        textColorDark: '#B37FEB',
        borderColorLight: '#D3ADF7',
        borderColorDark: 'rgba(146, 84, 222, 0.3)'
      };
    }

    // 5. 君子兰：伞形橙朱花序
    if (key.indexOf('君子兰') !== -1 || key.indexOf('junzi') !== -1) {
      return {
        bgColorLight: '#FFF2E8',
        bgColorDark: 'rgba(120, 60, 30, 0.35)',
        badgeSymbol: '🏵️',
        subSymbol: '🌿',
        textColorLight: '#D4380D',
        textColorDark: '#FF7A45',
        borderColorLight: '#FFBB96',
        borderColorDark: 'rgba(255, 122, 69, 0.3)'
      };
    }

    // 6. 月季：重瓣绯红玫瑰花
    if (key.indexOf('月季') !== -1 || key.indexOf('yueji') !== -1 || key.indexOf('玫瑰') !== -1 || key.indexOf('蔷薇') !== -1) {
      return {
        bgColorLight: '#FFF0F0',
        bgColorDark: 'rgba(130, 40, 50, 0.35)',
        badgeSymbol: '🌹',
        subSymbol: '✨',
        textColorLight: '#CF1322',
        textColorDark: '#FF4D4F',
        borderColorLight: '#FFA39E',
        borderColorDark: 'rgba(245, 34, 45, 0.3)'
      };
    }

    // 7. 玉露：晶莹多肉琉璃莲座
    if (key.indexOf('玉露') !== -1 || key.indexOf('yulu') !== -1 || key.indexOf('多肉') !== -1) {
      return {
        bgColorLight: '#E6FFFB',
        bgColorDark: 'rgba(20, 90, 95, 0.35)',
        badgeSymbol: '💎',
        subSymbol: '🌱',
        textColorLight: '#08979C',
        textColorDark: '#36CFC9',
        borderColorLight: '#87E8DE',
        borderColorDark: 'rgba(19, 194, 194, 0.3)'
      };
    }

    // 8. 仙客来：兔耳反卷仙客花
    if (key.indexOf('仙客来') !== -1 || key.indexOf('xiank') !== -1) {
      return {
        bgColorLight: '#FFF0F6',
        bgColorDark: 'rgba(120, 40, 80, 0.35)',
        badgeSymbol: '🌺',
        subSymbol: '🐰',
        textColorLight: '#C41D7F',
        textColorDark: '#FF85C0',
        borderColorLight: '#FFADD2',
        borderColorDark: 'rgba(235, 47, 150, 0.3)'
      };
    }

    // 9. 琴叶榕：大提琴形阔叶
    if (key.indexOf('琴叶') !== -1 || key.indexOf('qiye') !== -1 || key.indexOf('榕') !== -1) {
      return {
        bgColorLight: '#EEF7F2',
        bgColorDark: 'rgba(35, 80, 60, 0.35)',
        badgeSymbol: '🍃',
        subSymbol: '🎻',
        textColorLight: '#237804',
        textColorDark: '#73D13D',
        borderColorLight: '#B7EB8F',
        borderColorDark: 'rgba(82, 196, 26, 0.3)'
      };
    }

    // 10. 文竹：层叠云竹
    if (key.indexOf('文竹') !== -1 || key.indexOf('wenzhu') !== -1 || key.indexOf('竹') !== -1) {
      return {
        bgColorLight: '#F6FFED',
        bgColorDark: 'rgba(40, 85, 45, 0.35)',
        badgeSymbol: '🎋',
        subSymbol: '☁️',
        textColorLight: '#389E0D',
        textColorDark: '#95DE64',
        borderColorLight: '#D9F7BE',
        borderColorDark: 'rgba(115, 209, 61, 0.3)'
      };
    }

    // 11. 朱顶红：朱红硕大号角花
    if (key.indexOf('朱顶红') !== -1 || key.indexOf('zhuding') !== -1) {
      return {
        bgColorLight: '#FFF1F0',
        bgColorDark: 'rgba(130, 45, 45, 0.35)',
        badgeSymbol: '🏵️',
        subSymbol: '🎺',
        textColorLight: '#F5222D',
        textColorDark: '#FFA39E',
        borderColorLight: '#FFCCC7',
        borderColorDark: 'rgba(255, 77, 79, 0.3)'
      };
    }

    // 12. 茉莉花：洁白重瓣清香素花
    if (key.indexOf('茉莉') !== -1 || key.indexOf('moli') !== -1 || key.indexOf('白') !== -1) {
      return {
        bgColorLight: '#FBFDF8',
        bgColorDark: 'rgba(60, 75, 65, 0.35)',
        badgeSymbol: '🌼',
        subSymbol: '❄️',
        textColorLight: '#597050',
        textColorDark: '#B7CEAE',
        borderColorLight: '#D3DFCC',
        borderColorDark: 'rgba(160, 185, 150, 0.3)'
      };
    }

    // 默认通用绿植花卉
    return {
      bgColorLight: '#F4F7F2',
      bgColorDark: 'rgba(50, 70, 60, 0.35)',
      badgeSymbol: '🌿',
      subSymbol: '✨',
      textColorLight: '#388E6D',
      textColorDark: '#8EE0D0',
      borderColorLight: '#C3E8D8',
      borderColorDark: 'rgba(100, 200, 160, 0.3)'
    };
  }
}

@Component
export struct PlantIcon {
  @Prop plantName: string = '';
  @Prop sizeVal: number = 44; // 容器尺寸：28, 36, 44, 56, 72 等
  @Prop isDark: boolean = false;
  @Prop showSubBadge: boolean = true;
  @Prop customIcon: string = '';

  private getConf(): PlantVisualConfig {
    return PlantIconProvider.getConfig(this.plantName);
  }

  build() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      // 1. 底盘容器
      Column() {
        Text(this.customIcon ? this.customIcon : this.getConf().badgeSymbol)
          .fontSize(this.sizeVal * 0.52)
      }
      .width(this.sizeVal)
      .height(this.sizeVal)
      .borderRadius(this.sizeVal * 0.35)
      .backgroundColor(this.isDark ? this.getConf().bgColorDark : this.getConf().bgColorLight)
      .borderWidth(1)
      .borderColor(this.isDark ? this.getConf().borderColorDark : this.getConf().borderColorLight)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .shadow({
        radius: 8,
        color: this.isDark ? 'rgba(0,0,0,0.35)' : 'rgba(80, 120, 90, 0.10)',
        offsetY: 2
      })

      // 2. 特征微标 (角标)
      if (this.showSubBadge && this.sizeVal >= 36) {
        Column() {
          Text(this.getConf().subSymbol)
            .fontSize(this.sizeVal * 0.26)
        }
        .width(this.sizeVal * 0.38)
        .height(this.sizeVal * 0.38)
        .borderRadius(this.sizeVal * 0.19)
        .backgroundColor(this.isDark ? '#231B36' : '#FFFFFF')
        .borderWidth(0.5)
        .borderColor(this.isDark ? 'rgba(255,255,255,0.15)' : 'rgba(0,0,0,0.08)')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .offset({ x: 2, y: 2 })
      }
    }
    .width(this.sizeVal + 2)
    .height(this.sizeVal + 2)
  }
}
