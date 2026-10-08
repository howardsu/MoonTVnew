# 从上游 Stardm0/MoonTV 同步更新到你的 fork，并强制保留你自己的 config.json
# 用法：在仓库目录执行  .\sync-upstream.ps1
$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

Write-Host "[1/4] 拉取上游更新..."
git fetch upstream
if ($LASTEXITCODE -ne 0) { Write-Host "fetch 失败"; exit 1 }

Write-Host "[2/4] 合并 upstream/main..."
git merge upstream/main --no-commit

if (-not (git rev-parse -q --verify MERGE_HEAD)) {
    Write-Host "已经是最新的，无需更新。" -ForegroundColor Green
    exit 0
}

Write-Host "[3/4] 强制保留你自己的 config.json..."
git checkout HEAD -- config.json
git add config.json

$unmerged = git diff --name-only --diff-filter=U
if ($unmerged) {
    Write-Host "`n以下文件还有冲突需要你手动解决：" -ForegroundColor Yellow
    $unmerged | ForEach-Object { Write-Host "  $_" }
    Write-Host "`n解决后执行："
    Write-Host "  git add <文件>"
    Write-Host "  git commit -m `"Merge upstream`""
    Write-Host "  git push origin main"
    exit 1
}

Write-Host "[4/4] 提交并推送到你的仓库（Cloudflare Pages 会自动部署）..."
git commit -m "Merge upstream Stardm0/MoonTV main"
if ($LASTEXITCODE -ne 0) { Write-Host "commit 失败"; exit 1 }

git push origin main
if ($LASTEXITCODE -ne 0) { Write-Host "push 失败"; exit 1 }

Write-Host "完成！上游更新已同步，config.json 保持你自己的版本。" -ForegroundColor Green
