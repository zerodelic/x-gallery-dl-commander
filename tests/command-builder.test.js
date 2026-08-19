import { describe, test, expect } from 'vitest';
import {
  buildURLs,
  buildFilenamePattern,
  buildMediaFilter,
  buildOptionLines,
  buildCommand,
} from './command-builder.js';

const baseState = {
  filename: 'default',
  directory: '~/Downloads/x_media',
  photo: true, video: true, gif: false,
  range: 50,
  sleep: false, noskip: false, orig: false, metadata: false,
};

// ── buildURLs ──────────────────────────────────────────────

describe('buildURLs', () => {
  test('ハッシュタグ単体のURLを生成する', () => {
    const urls = buildURLs('hashtag', '風景写真');
    expect(urls).toHaveLength(1);
    expect(urls[0]).toContain('x.com/search');
    expect(urls[0]).toContain('%23');
    expect(urls[0]).toContain('f=media');
  });

  test('複数ハッシュタグでURLを複数生成する', () => {
    const urls = buildURLs('hashtag', '風景写真, cats, #landscape');
    expect(urls).toHaveLength(3);
    expect(urls[2]).toContain('landscape');
  });

  test('# 付きハッシュタグを正規化する', () => {
    const urls = buildURLs('hashtag', '#cats');
    expect(urls[0]).toContain(encodeURIComponent('cats'));
    // URLテンプレート自体が検索構文として '%23' を1つ含む仕様。
    // 入力側の先頭 '#' が正しく除去されていれば '%23' は1回しか現れない
    // （除去し忘れると '#cats' → '%23cats' に二重エンコードされ '%23%23cats' になる）
    const occurrences = (urls[0].match(/%23/g) || []).length;
    expect(occurrences).toBe(1);
  });

  test('ハッシュタグ未入力でnullを返す', () => {
    expect(buildURLs('hashtag', '')).toBeNull();
    expect(buildURLs('hashtag', '  ')).toBeNull();
  });

  test('ユーザーメディアのURLを生成する', () => {
    const urls = buildURLs('user_media', '', 'testuser');
    expect(urls[0]).toBe('https://x.com/testuser/media');
  });

  test('ユーザーいいねのURLを生成する', () => {
    const urls = buildURLs('user_likes', '', 'testuser');
    expect(urls[0]).toBe('https://x.com/testuser/likes');
  });

  test('ユーザー名未入力でnullを返す', () => {
    expect(buildURLs('user_media', '', '')).toBeNull();
  });

  test('単一ツイートのURLをそのまま使う', () => {
    const url = 'https://x.com/user/status/123456789';
    const urls = buildURLs('tweet', '', '', url);
    expect(urls[0]).toBe(url);
  });

  test('ツイートURL未入力でnullを返す', () => {
    expect(buildURLs('tweet', '', '', '')).toBeNull();
  });

  test('キーワード検索のURLを生成する', () => {
    const urls = buildURLs('keyword', '猫 かわいい');
    expect(urls).toHaveLength(1);
    expect(urls[0]).toContain('x.com/search');
    expect(urls[0]).toContain(encodeURIComponent('猫 かわいい'));
    expect(urls[0]).toContain('f=media');
    expect(urls[0]).not.toContain('%23');
  });

  test('キーワード未入力でnullを返す', () => {
    expect(buildURLs('keyword', '')).toBeNull();
    expect(buildURLs('keyword', '  ')).toBeNull();
  });
});

// ── buildFilenamePattern ───────────────────────────────────

describe('buildFilenamePattern', () => {
  test('標準パターン', () => {
    expect(buildFilenamePattern('default'))
      .toBe('{user[name]}_{tweet_id}_{num}.{extension}');
  });

  test('日付入りパターン', () => {
    const p = buildFilenamePattern('date');
    expect(p).toContain('{date:');
    expect(p).toContain('{user[name]}');
  });

  test('カスタムパターンを使う', () => {
    expect(buildFilenamePattern('custom', 'my_{num}.{extension}'))
      .toBe('my_{num}.{extension}');
  });

  test('カスタム未入力はデフォルトパターンにフォールバック', () => {
    expect(buildFilenamePattern('custom', ''))
      .toBe('{user[name]}_{tweet_id}_{num}.{extension}');
  });
});

// ── buildMediaFilter ───────────────────────────────────────

describe('buildMediaFilter', () => {
  test('全種別選択でフィルターなし（null）', () => {
    expect(buildMediaFilter(true, true, true)).toBeNull();
  });

  test('全種別未選択でnull', () => {
    expect(buildMediaFilter(false, false, false)).toBeNull();
  });

  test('写真のみ選択', () => {
    const f = buildMediaFilter(true, false, false);
    expect(f).toContain("'jpg'");
    expect(f).toContain("'png'");
    expect(f).not.toContain("'mp4'");
    expect(f).not.toContain("'gif'");
  });

  test('動画のみ選択', () => {
    const f = buildMediaFilter(false, true, false);
    expect(f).toContain("'mp4'");
    expect(f).not.toContain("'jpg'");
  });

  test('GIFのみ選択', () => {
    const f = buildMediaFilter(false, false, true);
    expect(f).toContain("'gif'");
    expect(f).not.toContain("'mp4'");
  });
});

// ── buildOptionLines（最高画質オプション）─────────────────

describe('buildOptionLines - 最高画質オプション', () => {
  test('orig=true で extractor.twitter.size=orig を含む', () => {
    const lines = buildOptionLines({ ...baseState, orig: true }).join('\n');
    expect(lines).toContain('extractor.twitter.size=orig');
  });

  test('orig=true で extractor.x.size=orig を含む（新バージョン対応）', () => {
    const lines = buildOptionLines({ ...baseState, orig: true }).join('\n');
    expect(lines).toContain('extractor.x.size=orig');
  });

  test('orig=false でサイズオプションを含まない', () => {
    const lines = buildOptionLines({ ...baseState, orig: false }).join('\n');
    expect(lines).not.toContain('extractor');
  });

  test('twitter と x の両方を指定する（新旧バージョン互換）', () => {
    const lines = buildOptionLines({ ...baseState, orig: true });
    const twitterCount = lines.filter(l => l.includes('extractor.twitter.size=orig')).length;
    const xCount       = lines.filter(l => l.includes('extractor.x.size=orig')).length;
    expect(twitterCount).toBe(1);
    expect(xCount).toBe(1);
  });
});

// ── buildOptionLines（各種オプション）─────────────────────

describe('buildOptionLines - その他オプション', () => {
  test('sleep=true で --sleep 2 を含む', () => {
    const lines = buildOptionLines({ ...baseState, sleep: true }).join('\n');
    expect(lines).toContain('--sleep 2');
  });

  test('noskip=true で --no-skip を含む', () => {
    const lines = buildOptionLines({ ...baseState, noskip: true }).join('\n');
    expect(lines).toContain('--no-skip');
  });

  test('metadata=true で --write-metadata を含む', () => {
    const lines = buildOptionLines({ ...baseState, metadata: true }).join('\n');
    expect(lines).toContain('--write-metadata');
  });

  test('range=0 で --range を含まない', () => {
    const lines = buildOptionLines({ ...baseState, range: 0 }).join('\n');
    expect(lines).not.toContain('--range');
  });

  test('range=100 で --range 1-100 を含む', () => {
    const lines = buildOptionLines({ ...baseState, range: 100 }).join('\n');
    expect(lines).toContain('--range 1-100');
  });

  test('日付範囲オプション', () => {
    const lines = buildOptionLines({
      ...baseState,
      dateAfter: '2026-01-01',
      dateBefore: '2026-03-31',
    }).join('\n');
    expect(lines).toContain('--date-after  2026-01-01');
    expect(lines).toContain('--date-before 2026-03-31');
  });
});

// ── buildCommand ───────────────────────────────────────────

describe('buildCommand', () => {
  test('取得対象未入力でnullを返す', () => {
    expect(buildCommand({ ...baseState, type: 'hashtag', hashtag: '' })).toBeNull();
  });

  test('コマンドが gallery-dl で始まる', () => {
    const cmd = buildCommand({ ...baseState, type: 'hashtag', hashtag: 'cats' });
    expect(cmd).toMatch(/^gallery-dl/);
  });

  test('URLがコマンドに含まれる', () => {
    const cmd = buildCommand({ ...baseState, type: 'user_media', username: 'testuser' });
    expect(cmd).toContain('https://x.com/testuser/media');
  });

  test('複数ハッシュタグで空行区切りの複数コマンドブロック', () => {
    const cmd = buildCommand({ ...baseState, type: 'hashtag', hashtag: 'cats, dogs' });
    expect(cmd).toContain('\n\n');
    expect(cmd?.match(/gallery-dl/g)).toHaveLength(2);
  });

  test('--cookies-from-browser chrome を必ず含む', () => {
    const cmd = buildCommand({ ...baseState, type: 'hashtag', hashtag: 'cats' });
    expect(cmd).toContain('--cookies-from-browser chrome');
  });
});
