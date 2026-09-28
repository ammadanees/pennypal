const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

const rootDir = path.resolve(__dirname, '..');
const mdPath = path.join(rootDir, 'docs', 'PennyPal_Project_Documentation_Report.md');
const htmlPath = path.join(rootDir, 'docs', 'PennyPal_Project_Documentation_Report.html');
const pdfPath = path.join(rootDir, 'docs', 'PennyPal_Project_Documentation_Report.pdf');

const src = fs.readFileSync(mdPath, 'utf8');

function markdownToHtml(md) {
  const lines = md.split(/\r?\n/);
  let inCode = false;
  let codeLang = '';
  let codeContent = [];
  let inTable = false;
  let tableLines = [];
  const html = [];

  function flushTable() {
    if (tableLines.length === 0) return;
    let res = '<table style="width:100%; border-collapse:separate; border-spacing:0; margin:14px 0; border-radius:8px; overflow:hidden; border:1.5px solid #C7D2FE; font-size:12.5px; background:#FFFFFF; box-shadow:0 2px 5px rgba(0,0,0,0.03); page-break-inside:auto !important;">\n';
    let isHeader = true;
    for (let r = 0; r < tableLines.length; r++) {
      let line = tableLines[r].trim();
      if (line.includes(':---') || line.includes('---:')) {
        isHeader = false;
        continue;
      }
      let cells = line.split('|');
      // slice off leading and trailing empty elements
      if (cells.length >= 2) {
        cells = cells.slice(1, cells.length - 1);
      }
      if (isHeader) {
        res += '  <thead><tr style="page-break-inside:avoid !important;">\n';
        cells.forEach(c => {
          res += '    <th style="background:linear-gradient(135deg, #1E1B4B 0%, #4338CA 100%); color:#FFFFFF !important; font-weight:700; text-align:left; padding:9px 12px; border:none; letter-spacing:0.3px;">' + c.trim() + '</th>\n';
        });
        res += '  </tr></thead>\n  <tbody>\n';
      } else {
        res += '  <tr style="page-break-inside:avoid !important;">\n';
        cells.forEach(c => {
          res += '    <td style="padding:7px 11px; border-bottom:1px solid #E2E8F0; border-right:1px solid #F1F5F9; color:#334155;">' + c.trim() + '</td>\n';
        });
        res += '  </tr>\n';
      }
    }
    res += '  </tbody>\n</table>';
    html.push(res);
    tableLines = [];
    inTable = false;
  }

  function flushCode() {
    if (!inCode) return;
    html.push('<pre style="background:#0F172A; color:#E2E8F0; border-radius:8px; padding:10px 14px; border:1px solid #334155; font-family:\'JetBrains Mono\', monospace; font-size:11px; line-height:1.4; white-space:pre-wrap; word-break:break-word; page-break-inside:auto !important;"><code>' + 
      codeContent.join('\n').replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;') + 
      '</code></pre>');
    codeContent = [];
    inCode = false;
  }

  for (let i = 0; i < lines.length; i++) {
    let line = lines[i];

    if (line.trim().startsWith('```')) {
      if (inCode) {
        flushCode();
      } else {
        if (inTable) flushTable();
        inCode = true;
        codeLang = line.trim().slice(3);
        codeContent = [];
      }
      continue;
    }

    if (inCode) {
      codeContent.push(line);
      continue;
    }

    if (line.trim().startsWith('|') && line.trim().endsWith('|')) {
      inTable = true;
      tableLines.push(line);
      continue;
    } else if (inTable) {
      flushTable();
    }

    // Markdown headers
    if (line.startsWith('## ')) {
      html.push('<h2 style="color:#FFFFFF !important; font-size:17px !important; font-weight:700 !important; background:linear-gradient(135deg, #1E1B4B 0%, #312E81 40%, #4F46E5 100%) !important; padding:8px 14px !important; margin-top:26px !important; margin-bottom:14px !important; border-radius:6px !important; border:none !important; page-break-after:avoid !important;">' + line.slice(3) + '</h2>');
      continue;
    }
    if (line.startsWith('### ')) {
      html.push('<h3 style="color:#3730A3 !important; font-size:15px !important; font-weight:700 !important; border-left:4px solid #4F46E5 !important; padding-left:10px !important; margin-top:20px !important; margin-bottom:8px !important; page-break-after:avoid !important;">' + line.slice(4) + '</h3>');
      continue;
    }
    if (line.startsWith('#### ')) {
      html.push('<h4 style="color:#475569 !important; font-size:13.5px !important; font-weight:600 !important; margin-top:14px !important; margin-bottom:6px !important; page-break-after:avoid !important;">' + line.slice(5) + '</h4>');
      continue;
    }

    // Horizontal rule
    if (line.trim() === '---') {
      html.push('<hr style="border:none; height:1px; background:#E2E8F0; margin:20px 0; page-break-before:avoid !important; page-break-after:avoid !important;" />');
      continue;
    }

    // Pass through HTML or normal paragraph lines
    html.push(line);
  }

  if (inCode) flushCode();
  if (inTable) flushTable();

  return html.join('\n');
}

const htmlBody = markdownToHtml(src);

let finalHtml = htmlBody
  .replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>')
  .replace(/\[(.*?)\]\((.*?)\)/g, '<a href="$2" style="color:#4F46E5; text-decoration:none; font-weight:600;">$1</a>')
  .replace(/`([^`]+)`/g, '<code style="font-family:\'JetBrains Mono\', monospace; background:#EEF2FF; color:#4338CA; padding:2px 5px; border-radius:4px; font-size:12px;">$1</code>');

const fullDoc = `<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>PennyPal — Project Documentation Report</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<style>
  @import url('https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=JetBrains+Mono:wght@400;500&display=swap');
  @page {
    size: A4 portrait;
    margin: 12mm 12mm 12mm 12mm;
  }
  * {
    -webkit-print-color-adjust: exact !important;
    print-color-adjust: exact !important;
    box-sizing: border-box;
  }
  body {
    font-family: 'Plus Jakarta Sans', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
    color: #1E293B;
    background: #FFFFFF;
    line-height: 1.55;
    font-size: 13.5px;
    max-width: 920px;
    margin: 0 auto;
    padding: 24px;
  }
  @media print {
    body {
      padding: 0;
      max-width: 100%;
      font-size: 9.5pt;
      line-height: 1.38;
    }
  }
</style>
</head>
<body>
${finalHtml}
</body>
</html>`;

fs.writeFileSync(htmlPath, fullDoc, 'utf8');
console.log('Successfully written:', htmlPath);

// Generate PDF via Chrome Headless
const chromePaths = [
  'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe',
  'C:\\Program Files (x86)\\Microsoft\\Edge\\Application\\msedge.exe'
];

let browserPath = chromePaths.find(p => fs.existsSync(p));

if (browserPath) {
  console.log('Using browser for PDF compilation:', browserPath);
  try {
    const cmd = `"${browserPath}" --headless=new --disable-gpu --no-pdf-header-footer --print-to-pdf="${pdfPath}" "${htmlPath}"`;
    execSync(cmd, { stdio: 'inherit' });
    console.log('Successfully generated blank-page-free, vibrant PDF at:', pdfPath);
    const stats = fs.statSync(pdfPath);
    console.log('PDF File Size:', stats.size, 'bytes');
  } catch (err) {
    console.error('Browser PDF generation error:', err.message);
  }
}
