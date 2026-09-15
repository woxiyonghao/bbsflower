import { describe, beforeEach, it, expect } from '@ohos/hypium';
import { exists, tap, waitFor, openApp, goto, backToTabs, sleep, assertOnScreen, logStep } from './UiDriver';

/** 界面结构断言：关键元素必须存在、在屏幕内且尺寸非零 */
export default function uiAnomalyTest() {
  describe('BBoxUiAnomaly', () => {
    beforeEach(async () => {
      await openApp();
    });

    it('UA-01_home_elements_on_screen', 0, async () => {
      logStep('UA-01 首页关键元素在屏内');
      await goto('今日');
      await assertOnScreen('琉璃花语');
      await assertOnScreen('每日花语');
      await assertOnScreen('今日待办养护');
      await assertOnScreen('添置花盆');
      await assertOnScreen('记篇日记');
      await assertOnScreen('雅舍');
    });

    it('UA-02_tab_elements_on_screen', 0, async () => {
      logStep('UA-02 各 Tab 锚点在屏内');
      await goto('花园');
      expect(await waitFor('我的花园', 5000)).assertTrue();
      await assertOnScreen('我的花园');
      await assertOnScreen('＋ 添置新绿');
      await goto('日历');
      expect(await waitFor('养护日历', 5000)).assertTrue();
      await assertOnScreen('养护日历');
      await goto('百科');
      expect(await waitFor('百花图鉴', 5000)).assertTrue();
      await assertOnScreen('百花图鉴');
      await goto('雅舍');
      expect(await waitFor('琉璃雅舍', 5000)).assertTrue();
      await assertOnScreen('琉璃雅舍');
    });

    it('UA-03_secondary_pages_on_screen', 0, async () => {
      logStep('UA-03 二级页锚点在屏内');
      await goto('花园');
      await tap('＋ 添置新绿');
      expect(await waitFor('选择花木品种（点击自动关联）', 6000)).assertTrue();
      await assertOnScreen('花草爱称 / 昵称');
      await assertOnScreen('确认收进我的花园');
      await backToTabs();

      await goto('雅舍');
      await tap('⚙️ 系统设置');
      await sleep(600);
      await tap('📥 数据备份与恢复');
      expect(await waitFor('全量沙盒数据 JSON', 6000)).assertTrue();
      await assertOnScreen('全量沙盒数据 JSON');
      await backToTabs();
    });
  });
}
