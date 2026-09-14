import { describe, beforeEach, it, expect } from '@ohos/hypium';
import {
  exists, tap, waitFor, openApp, goto, backToTabs, sleep, shot, countText,
  typeInto, findText, logStep
} from './UiDriver';

/** 边界与校验：空值、纯空白、超长文本、步进器上下限、非法输入 */
export default function boundaryTest() {
  describe('BBoxBoundary', () => {
    beforeEach(async () => {
      await openApp();
    });

    it('BD-01_add_plant_empty_nickname_falls_back', 0, async () => {
      logStep('BD-01 昵称留空提交：应回退为默认昵称并成功入册');
      await goto('花园');
      const before: number = await countText('档案');
      await tap('＋ 添置新绿');
      expect(await waitFor('花草爱称 / 昵称', 6000)).assertTrue();
      expect(await typeInto('TextInput', 0, '')).assertTrue();
      expect(await tap('确认收进我的花园')).assertTrue();
      expect(await waitFor('我的花园', 6000)).assertTrue();
      await sleep(600);
      const after: number = await countText('档案');
      expect(after > before).assertTrue();
      await shot('BD-01_empty_nickname_saved');
    });

    it('BD-02_add_plant_long_nickname_saved', 0, async () => {
      logStep('BD-02 超长昵称（30 字）提交：不应崩溃，应正常入册');
      const longName: string = '超长昵称测试超长昵称测试超长昵称测试超长昵称测试超长昵称测试';
      await goto('花园');
      const before: number = await countText('档案');
      await tap('＋ 添置新绿');
      expect(await waitFor('花草爱称 / 昵称', 6000)).assertTrue();
      expect(await typeInto('TextInput', 0, longName)).assertTrue();
      await shot('BD-02_long_nickname_input');
      expect(await tap('确认收进我的花园')).assertTrue();
      expect(await waitFor('我的花园', 6000)).assertTrue();
      await sleep(600);
      const after: number = await countText('档案');
      expect(after > before).assertTrue();
      expect(await exists('超长昵称测试超长昵称测试', true)).assertTrue();
    });

    it('BD-03_add_plant_whitespace_nickname_rejected', 0, async () => {
      logStep('BD-03 纯空白昵称提交：期望回退为默认昵称，不应出现空白植物名');
      await goto('花园');
      await tap('＋ 添置新绿');
      expect(await waitFor('花草爱称 / 昵称', 6000)).assertTrue();
      expect(await typeInto('TextInput', 0, '     ')).assertTrue();
      expect(await tap('确认收进我的花园')).assertTrue();
      expect(await waitFor('我的花园', 6000)).assertTrue();
      await sleep(800);
      await shot('BD-03_whitespace_nickname');
      const blankStored: boolean = await exists('     ');
      expect(blankStored).assertFalse();
    });

    it('BD-04_water_interval_lower_bound', 0, async () => {
      logStep('BD-04 浇水周期减到下限：不应低于 1 天');
      await goto('花园');
      await tap('＋ 添置新绿');
      expect(await waitFor('建议浇水周期', 6000)).assertTrue();
      for (let i = 0; i < 12; i++) {
        await tap('－');
      }
      expect(await exists('1 天')).assertTrue();
      await shot('BD-04_water_interval_min');
    });

    it('BD-05_water_interval_increase', 0, async () => {
      logStep('BD-05 浇水周期加 15 次：从 5 天到 20 天');
      await goto('花园');
      await tap('＋ 添置新绿');
      expect(await waitFor('建议浇水周期', 6000)).assertTrue();
      for (let i = 0; i < 15; i++) {
        await tap('＋');
      }
      expect(await exists('20 天')).assertTrue();
    });

    it('BD-06_fertilize_interval_lower_bound', 0, async () => {
      logStep('BD-06 施肥周期减到下限：不应低于 5 天');
      await goto('花园');
      await tap('＋ 添置新绿');
      expect(await waitFor('建议施肥周期', 6000)).assertTrue();
      for (let i = 0; i < 10; i++) {
        await tap('－');
      }
      expect(await exists('5 天')).assertTrue();
    });

    it('BD-07_diary_empty_title_blocked', 0, async () => {
      logStep('BD-07 日记标题为空：应被拦截，停留在新增日记页');
      await goto('今日');
      await tap('记篇日记');
      expect(await waitFor('日记标题', 6000)).assertTrue();
      expect(await typeInto('TextInput', 0, '')).assertTrue();
      await shot('BD-07_empty_title');
      expect(await tap('写下这抹绿意')).assertTrue();
      await sleep(1200);
      expect(await exists('日记标题')).assertTrue();
      await backToTabs();
    });

    it('BD-08_diary_whitespace_title_blocked', 0, async () => {
      logStep('BD-08 日记标题纯空白：应被 trim 拦截，停留原页');
      await goto('今日');
      await tap('记篇日记');
      expect(await waitFor('日记标题', 6000)).assertTrue();
      expect(await typeInto('TextInput', 0, '    ')).assertTrue();
      expect(await tap('写下这抹绿意')).assertTrue();
      await sleep(1200);
      expect(await exists('日记标题')).assertTrue();
      await backToTabs();
    });

    it('BD-09_backup_import_empty_blocked', 0, async () => {
      logStep('BD-09 备份导入空数据：应提示且停留在备份页');
      await goto('雅舍');
      await tap('⚙️ 系统设置');
      await sleep(600);
      await tap('📥 数据备份与恢复');
      expect(await waitFor('全量沙盒数据 JSON', 6000)).assertTrue();
      expect(await tap('📥 导入与恢复')).assertTrue();
      await sleep(600);
      expect(await tap('确认解析并导入恢复')).assertTrue();
      await sleep(1200);
      await shot('BD-09_empty_import');
      expect(await exists('确认解析并导入恢复')).assertTrue();
      await backToTabs();
    });

    it('BD-10_backup_import_invalid_json_blocked', 0, async () => {
      logStep('BD-10 备份导入非法 JSON：应提示解析失败且不破坏现有数据');
      await goto('雅舍');
      await tap('⚙️ 系统设置');
      await sleep(600);
      await tap('📥 数据备份与恢复');
      expect(await waitFor('全量沙盒数据 JSON', 6000)).assertTrue();
      expect(await tap('📥 导入与恢复')).assertTrue();
      await sleep(600);
      expect(await typeInto('TextArea', 0, 'this-is-not-json')).assertTrue();
      expect(await tap('确认解析并导入恢复')).assertTrue();
      await sleep(1500);
      expect(await exists('确认解析并导入恢复')).assertTrue();

      await backToTabs();
      await goto('花园');
      expect(await waitFor('我的花园', 6000)).assertTrue();
      const cards: number = await countText('档案');
      expect(cards > 0).assertTrue();
    });
  });
}
