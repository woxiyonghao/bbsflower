import { describe, beforeEach, it, expect } from '@ohos/hypium';
import { exists, tap, waitFor, openApp, goto, backToTabs, sleep, shot, countText, logStep } from './UiDriver';

/** 全量可达性遍历：每个入口都要停留并断言锚点 */
export default function traversalTest() {
  describe('BBoxTraversal', () => {
    beforeEach(async () => {
      await openApp();
    });

    it('TR-01_five_tabs_switch_with_anchors', 0, async () => {
      logStep('TR-01 五个 Tab 均可切换且锚点正确');
      expect(await goto('今日')).assertTrue();
      expect(await waitFor('每日花语', 5000)).assertTrue();
      expect(await goto('花园')).assertTrue();
      expect(await waitFor('我的花园', 5000)).assertTrue();
      expect(await goto('日历')).assertTrue();
      expect(await waitFor('养护日历', 5000)).assertTrue();
      expect(await goto('百科')).assertTrue();
      expect(await waitFor('百花图鉴', 5000)).assertTrue();
      expect(await goto('雅舍')).assertTrue();
      expect(await waitFor('琉璃雅舍', 5000)).assertTrue();
      await shot('TR-01_mine_tab');
    });

    it('TR-02_home_quick_action_add_plant', 0, async () => {
      logStep('TR-02 今日-添置花盆 -> 新增花草页');
      await goto('今日');
      expect(await tap('添置花盆')).assertTrue();
      expect(await waitFor('选择花木品种（点击自动关联）', 6000)).assertTrue();
      expect(await exists('确认收进我的花园')).assertTrue();
      await shot('TR-02_add_plant_page');
      await backToTabs();
    });

    it('TR-03_home_quick_action_add_diary', 0, async () => {
      logStep('TR-03 今日-记篇日记 -> 新增日记页');
      await goto('今日');
      expect(await tap('记篇日记')).assertTrue();
      expect(await waitFor('日记标题', 6000)).assertTrue();
      expect(await exists('成长阶段标签')).assertTrue();
      await backToTabs();
    });

    it('TR-04_home_quick_action_share_summary', 0, async () => {
      logStep('TR-04 今日-绿意回顾 -> 时光回顾卡片');
      await goto('今日');
      expect(await tap('绿意回顾')).assertTrue();
      expect(await waitFor('养护时光回顾', 6000)).assertTrue();
      await shot('TR-04_share_summary');
      await backToTabs();
    });

    it('TR-05_home_all_footprints_page', 0, async () => {
      logStep('TR-05 今日-全部足迹 -> 全部足迹页');
      await goto('今日');
      expect(await tap('全部足迹')).assertTrue();
      expect(await waitFor('累计足迹', 6000)).assertTrue();
      expect(await exists('陪伴天数')).assertTrue();
      await shot('TR-05_footprints');
      await backToTabs();
    });

    it('TR-06_home_quick_care_updates_footprint', 0, async () => {
      logStep('TR-06 今日-完成施肥：待办减少且足迹新增');
      await goto('今日');
      const before: number = await countText('为「');
      const todoBefore: number = await countText('完成施肥');
      expect(todoBefore > 0).assertTrue();

      expect(await tap('完成施肥')).assertTrue();
      await sleep(800);

      let after: number = await countText('为「');
      let waited: number = 0;
      while (after <= before && waited < 6000) {
        await sleep(600);
        waited += 600;
        after = await countText('为「');
      }
      expect(after > before).assertTrue();
      await shot('TR-06_after_quick_care');
    });

    it('TR-07_garden_filters_and_empty_state', 0, async () => {
      logStep('TR-07 花园筛选：收藏置顶无匹配时展示空态，切回全部恢复列表');
      await goto('花园');
      expect(await tap('⭐ 收藏置顶')).assertTrue();
      await sleep(600);
      const emptyShown: boolean = await waitFor('暂无匹配的花草档案', 4000);
      expect(emptyShown).assertTrue();
      await shot('TR-07_garden_empty_filter');

      expect(await tap('全部植物')).assertTrue();
      await sleep(600);
      expect(await exists('暂无匹配的花草档案')).assertFalse();
    });

    it('TR-08_garden_add_plant_entry', 0, async () => {
      logStep('TR-08 花园-添置新绿入口');
      await goto('花园');
      expect(await tap('＋ 添置新绿')).assertTrue();
      expect(await waitFor('选择花木品种（点击自动关联）', 6000)).assertTrue();
      await backToTabs();
    });

    it('TR-09_garden_card_opens_plant_detail', 0, async () => {
      logStep('TR-09 花园卡片 -> 花草档案详情');
      await goto('花园');
      expect(await tap('档案')).assertTrue();
      expect(await waitFor('日常养护打卡', 6000)).assertTrue();
      expect(await exists('💧 下次浇水')).assertTrue();
      await shot('TR-09_plant_detail');
      await backToTabs();
    });

    it('TR-10_garden_quick_water_adds_log', 0, async () => {
      logStep('TR-10 花园-浇水：首页足迹新增');
      await goto('花园');
      const before: number = await countText('为「');
      expect(await tap('浇水')).assertTrue();
      await sleep(900);
      await goto('今日');
      let after: number = await countText('为「');
      let waited: number = 0;
      while (after <= before && waited < 6000) {
        await sleep(600);
        waited += 600;
        after = await countText('为「');
      }
      expect(after > before).assertTrue();
    });

    it('TR-11_calendar_month_switch_and_retrofit_entry', 0, async () => {
      logStep('TR-11 日历：月份切换 + 补记打卡入口');
      await goto('日历');
      expect(await waitFor('养护日历', 5000)).assertTrue();
      expect(await tap('❯')).assertTrue();
      await sleep(500);
      expect(await exists('养护日历')).assertTrue();
      expect(await tap('❮')).assertTrue();
      await sleep(500);
      expect(await exists('养护日历')).assertTrue();
      await shot('TR-11_calendar');

      expect(await tap('＋ 补记打卡')).assertTrue();
      expect(await waitFor('补记日期与时间', 6000)).assertTrue();
      await backToTabs();
    });

    it('TR-12_wiki_filter_and_species_detail', 0, async () => {
      logStep('TR-12 百科：分类筛选 + 要点详情');
      await goto('百科');
      expect(await waitFor('百花图鉴', 5000)).assertTrue();
      expect(await tap('🌸 观花花卉')).assertTrue();
      await sleep(600);
      expect(await exists('百花图鉴')).assertTrue();

      expect(await tap('要点')).assertTrue();
      expect(await waitFor('四维核心养护要素', 6000)).assertTrue();
      await shot('TR-12_species_detail');
      await backToTabs();
    });

    it('TR-13_wiki_add_to_garden_prefills', 0, async () => {
      logStep('TR-13 百科-入园：跳转新增页并预填品种');
      await goto('百科');
      expect(await tap('＋ 入园')).assertTrue();
      expect(await waitFor('选择花木品种（点击自动关联）', 6000)).assertTrue();
      expect(await exists('确认收进我的花园')).assertTrue();
      await backToTabs();
    });

    it('TR-14_mine_section_switching', 0, async () => {
      logStep('TR-14 雅舍三个栏目切换');
      await goto('雅舍');
      expect(await tap('📖 日记本')).assertTrue();
      await sleep(500);
      expect(await waitFor('＋ 记一篇', 5000)).assertTrue();
      expect(await exists('🎨 主题色彩与深色模式')).assertFalse();

      expect(await tap('⚙️ 系统设置')).assertTrue();
      await sleep(500);
      expect(await waitFor('🎨 主题色彩与深色模式', 5000)).assertTrue();
      expect(await exists('＋ 记一篇')).assertFalse();

      expect(await tap('🏆 成就徽章')).assertTrue();
      await sleep(500);
      expect(await exists('＋ 记一篇')).assertFalse();
      expect(await exists('🎨 主题色彩与深色模式')).assertFalse();
    });

    it('TR-15_mine_diary_entry_and_detail', 0, async () => {
      logStep('TR-15 雅舍-日记本：新增入口与日记详情');
      await goto('雅舍');
      await tap('📖 日记本');
      await sleep(600);
      const openAdd: boolean = await tap('＋ 记一篇');
      expect(openAdd).assertTrue();
      expect(await waitFor('日记标题', 6000)).assertTrue();
      await backToTabs();

      await goto('雅舍');
      await tap('📖 日记本');
      await sleep(600);
      const openedDetail: boolean = await tap('植物: ', true);
      if (openedDetail) {
        expect(await waitFor('日记详情', 6000)).assertTrue();
        await shot('TR-15_diary_detail');
      }
      await backToTabs();
    });

    it('TR-16_mine_settings_entries', 0, async () => {
      logStep('TR-16 雅舍-系统设置：时光回顾 / 备份恢复 / 隐私政策 三个入口');
      await goto('雅舍');
      await tap('⚙️ 系统设置');
      await sleep(600);

      expect(await tap('✨ 查看时光回顾卡片')).assertTrue();
      expect(await waitFor('养护时光回顾', 6000)).assertTrue();
      await backToTabs();

      await goto('雅舍');
      await tap('⚙️ 系统设置');
      await sleep(600);
      expect(await tap('📥 数据备份与恢复')).assertTrue();
      expect(await waitFor('全量沙盒数据 JSON', 6000)).assertTrue();
      await shot('TR-16_backup_page');
      await backToTabs();

      await goto('雅舍');
      await tap('⚙️ 系统设置');
      await sleep(600);
      expect(await tap('隐私政策与用户协议')).assertTrue();
      expect(await waitFor('纯单机离线承诺', 6000)).assertTrue();
      await backToTabs();
    });

    it('TR-17_theme_mode_switch_keeps_ui_alive', 0, async () => {
      logStep('TR-17 主题切换：深色/浅色切换后页面仍可用');
      await goto('雅舍');
      await tap('⚙️ 系统设置');
      await sleep(600);
      expect(await tap('🌙 深色模式')).assertTrue();
      await sleep(900);
      expect(await exists('琉璃雅舍')).assertTrue();
      await shot('TR-17_dark_mode');

      expect(await tap('☀️ 浅色模式')).assertTrue();
      await sleep(900);
      expect(await exists('琉璃雅舍')).assertTrue();
      await shot('TR-17_light_mode_restored');
    });
  });
}
