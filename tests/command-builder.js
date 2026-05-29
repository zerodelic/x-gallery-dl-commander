// Pure logic functions extracted from app/index.html and src/gallery-dl-commander.html
// Keep in sync with the HTML files when command generation logic changes.

export function buildURLs(type, hashtag = '', username = '', tweeturl = '') {
  switch (type) {
    case 'hashtag': {
      const tags = hashtag.split(',')
        .map(t => t.trim().replace(/^#/, ''))
        .filter(t => t.length > 0);
      if (!tags.length) return null;
      return tags.map(t => `https://x.com/search?q=%23${encodeURIComponent(t)}&f=media`);
    }
    case 'user_media':
      if (!username) return null;
      return [`https://x.com/${username}/media`];
    case 'user_likes':
      if (!username) return null;
      return [`https://x.com/${username}/likes`];
    case 'keyword': {
      const kw = hashtag.trim();
      if (!kw) return null;
      return [`https://x.com/search?q=${encodeURIComponent(kw)}&f=media`];
    }
    case 'tweet':
      return tweeturl ? [tweeturl] : null;
    default:
      return null;
  }
}

export function buildFilenamePattern(mode, customFname = '') {
  switch (mode) {
    case 'default': return '{user[name]}_{tweet_id}_{num}.{extension}';
    case 'date':    return '{date:%Y-%m-%d}_{user[name]}_{num}.{extension}';
    case 'custom':  return customFname || '{user[name]}_{tweet_id}_{num}.{extension}';
    default:        return '{user[name]}_{tweet_id}_{num}.{extension}';
  }
}

export function buildMediaFilter(photo, video, gif) {
  if (!photo && !video && !gif) return null;
  if (photo && video && gif) return null;
  const exts = [];
  if (photo) exts.push("'jpg'", "'png'", "'webp'");
  if (video) exts.push("'mp4'", "'m4v'");
  if (gif)   exts.push("'gif'");
  return `"extension in (${exts.join(', ')})"`;
}

export function buildOptionLines(state) {
  const lines = [];
  const fname = buildFilenamePattern(state.filename, state.customFname);
  const mediaFilter = buildMediaFilter(
    state.photo ?? true,
    state.video ?? true,
    state.gif   ?? false
  );

  lines.push('gallery-dl \\');
  lines.push('  --cookies-from-browser chrome \\');
  lines.push(`  --filename "${fname}" \\`);
  lines.push(`  --directory ${state.directory} \\`);
  if (mediaFilter)      lines.push(`  --filter ${mediaFilter} \\`);
  if (state.dateAfter)  lines.push(`  --date-after  ${state.dateAfter} \\`);
  if (state.dateBefore) lines.push(`  --date-before ${state.dateBefore} \\`);
  if (state.range > 0)  lines.push(`  --range 1-${state.range} \\`);
  if (state.sleep)      lines.push(`  --sleep 2 \\`);
  if (state.noskip)     lines.push(`  --no-skip \\`);
  if (state.orig) {
    lines.push('  --config-option extractor.twitter.size=orig \\');
    lines.push('  --config-option extractor.x.size=orig \\');
  }
  if (state.metadata)   lines.push('  --write-metadata \\');
  return lines;
}

export function buildCommand(state) {
  const urls = buildURLs(
    state.type,
    state.hashtag  ?? '',
    state.username ?? '',
    state.tweeturl ?? ''
  );
  if (!urls) return null;

  const allLines = [];
  urls.forEach((url, i) => {
    if (i > 0) allLines.push('');
    const optLines = buildOptionLines(state);
    const last = optLines[optLines.length - 1];
    if (!last.endsWith('\\')) optLines[optLines.length - 1] = last + ' \\';
    optLines.push(`  "${url}"`);
    allLines.push(...optLines);
  });
  return allLines.join('\n');
}
