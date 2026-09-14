/**
 * 黑盒 UI 驱动公共方法。
 * 仅通过「用户可见」的文本/导航来定位与断言，不读取应用数据层。
 */
import { Driver, ON, Component, MatchPattern } from '@ohos.UiTest';
import { abilityDelegatorRegistry } from '@kit.TestKit';
import { expect } from '@ohos/hypium';

export const BUNDLE: string = 'com.winheo.bbsdrink';
export const MODULE: string = 'entry';
export const ABILITY: string = 'EntryAbility';

let sharedDriver: Driver | null = null;

/** 全局复用一个 Driver，避免多套件并发创建驱动互相干扰 */
export function drv(): Driver {
  if (sharedDriver === null) {
    sharedDriver = Driver.create();
  }
  return sharedDriver;
}

export function sleep(ms: number): Promise<void> {
  return new Promise<void>((resolve: () => void) => {
    setTimeout(() => {
      resolve();
    }, ms);
  });
}

/** 拉起被测应用（不 force-stop，避免连带杀掉同 bundle 的测试进程） */
export async function relaunch(): Promise<void> {
  const delegator: abilityDelegatorRegistry.AbilityDelegator = abilityDelegatorRegistry.getAbilityDelegator();
  await delegator.startAbility({ bundleName: BUNDLE, abilityName: ABILITY, moduleName: MODULE });
  await sleep(2000);
}

/** 查找一次；UI 忙碌或不存在时返回 null（不抛异常） */
export async function findText(txt: string, contains: boolean): Promise<Component | null> {
  try {
    if (contains) {
      return await drv().findComponent(ON.text(txt, MatchPattern.CONTAINS));
    }
    return await drv().findComponent(ON.text(txt));
  } catch (e) {
    return null;
  }
}

export async function exists(txt: string, contains: boolean = false): Promise<boolean> {
  const c: Component | null = await findText(txt, contains);
  return c !== null;
}

/** 轮询等待文本出现（不使用 waitForComponent，避免超时后驱动仍被占用） */
export async function waitFor(txt: string, timeout: number = 6000, contains: boolean = false): Promise<boolean> {
  let elapsed: number = 0;
  while (elapsed < timeout) {
    if (await exists(txt, contains)) {
      return true;
    }
    await sleep(400);
    elapsed += 400;
  }
  return await exists(txt, contains);
}

export async function tap(txt: string, contains: boolean = false): Promise<boolean> {
  const c: Component | null = await findText(txt, contains);
  if (c === null) {
    return false;
  }
  try {
    await c.click();
  } catch (e) {
    return false;
  }
  await sleep(700);
  return true;
}

/** 统计屏幕上匹配到的元素个数（findComponents 无匹配时返回 null） */
export async function countText(txt: string, contains: boolean = true): Promise<number> {
  try {
    const list: Component[] = await drv().findComponents(
      contains ? ON.text(txt, MatchPattern.CONTAINS) : ON.text(txt)
    );
    if (list === null || list === undefined) {
      return 0;
    }
    return list.length;
  } catch (e) {
    return 0;
  }
}

/** 按组件类型查找第 index 个元素（findComponents 无匹配时返回 null） */
export async function findType(tp: string, index: number = 0): Promise<Component | null> {
  try {
    const list: Component[] = await drv().findComponents(ON.type(tp));
    if (list === null || list === undefined || list.length <= index) {
      return null;
    }
    return list[index];
  } catch (e) {
    return null;
  }
}

/** 向第 index 个指定类型输入框写入文本（先清空） */
export async function typeInto(tp: string, index: number, text: string): Promise<boolean> {
  const c: Component | null = await findType(tp, index);
  if (c === null) {
    return false;
  }
  try {
    await c.clearText();
    await sleep(300);
    if (text.length > 0) {
      await c.inputText(text);
    }
    await sleep(400);
    return true;
  } catch (e) {
    return false;
  }
}

/** 读取第 index 个指定类型输入框当前文本 */
export async function readInput(tp: string, index: number): Promise<string> {
  const c: Component | null = await findType(tp, index);
  if (c === null) {
    return '';
  }
  try {
    return await c.getText();
  } catch (e) {
    return '';
  }
}

/** 逐级返回，直到回到带底部胶囊导航的 Tab 根页 */
export async function backToTabs(): Promise<void> {
  for (let i = 0; i < 6; i++) {
    const onTabs: boolean = (await exists('雅舍')) && (await exists('今日'));
    if (onTabs) {
      return;
    }
    try {
      await drv().pressBack();
    } catch (e) {
    }
    await sleep(600);
  }
}

/** 打开应用并确保停在 Tab 根页；首次启动的隐私弹窗会自动同意（弹窗专项用例另行验证） */
export async function openApp(): Promise<void> {
  await relaunch();
  if (await exists('同意并开启')) {
    await tap('同意并开启');
    await sleep(1000);
  }
  await backToTabs();
  if (!(await exists('雅舍'))) {
    await relaunch();
    await backToTabs();
  }
}

/** 切换底部 Tab（先退回根页，避免二级页仍在路由栈顶） */
export async function goto(tab: string): Promise<boolean> {
  await backToTabs();
  const ok: boolean = await tap(tab);
  await sleep(500);
  return ok;
}

export async function shot(name: string): Promise<void> {
  try {
    await drv().screenCapture('/data/local/tmp/' + name + '.png');
  } catch (e) {
  }
}

/** 结构断言：元素存在且在屏幕内、尺寸非零 */
export async function assertOnScreen(txt: string, contains: boolean = false): Promise<void> {
  const size = await drv().getDisplaySize();
  const c: Component | null = await findText(txt, contains);
  expect(c !== null).assertTrue();
  if (c === null) {
    return;
  }
  const r = await c.getBounds();
  expect(r.right > r.left).assertTrue();
  expect(r.bottom > r.top).assertTrue();
  expect(r.left >= 0).assertTrue();
  expect(r.top >= 0).assertTrue();
  expect(r.right <= size.x).assertTrue();
  expect(r.bottom <= size.y).assertTrue();
}

export function logStep(msg: string): void {
  console.info('[BBOX] ' + msg);
}
