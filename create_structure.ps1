# create_structure.ps1
$projectRoot = "D:\Study\Flutter\moviemaster\lib"

function Create-Directory {
    param([string]$path)
    if (-not (Test-Path $path)) {
        New-Item -ItemType Directory -Path $path -Force | Out-Null
        Write-Host "Created: $path"
    }
}

# Core layer
Create-Directory "$projectRoot\core\api\clients"
Create-Directory "$projectRoot\core\api\endpoints"
Create-Directory "$projectRoot\core\api\models"
Create-Directory "$projectRoot\core\api\interceptors"
Create-Directory "$projectRoot\core\api\transformers"

Create-Directory "$projectRoot\core\constants"
Create-Directory "$projectRoot\core\di\modules"
Create-Directory "$projectRoot\core\errors\exceptions"
Create-Directory "$projectRoot\core\errors\failures"
Create-Directory "$projectRoot\core\extensions"
Create-Directory "$projectRoot\core\localization\arb_files"
Create-Directory "$projectRoot\core\navigation\middlewares"
Create-Directory "$projectRoot\core\storage\local\database\dao"
Create-Directory "$projectRoot\core\storage\local\database\entities"
Create-Directory "$projectRoot\core\storage\local\preferences"
Create-Directory "$projectRoot\core\storage\local\cache"
Create-Directory "$projectRoot\core\storage\remote\firebase"
Create-Directory "$projectRoot\core\themes"
Create-Directory "$projectRoot\core\utils\validators"
Create-Directory "$projectRoot\core\utils\formatters"
Create-Directory "$projectRoot\core\utils\helpers"
Create-Directory "$projectRoot\core\utils\mixins"
Create-Directory "$projectRoot\core\utils\enums"
Create-Directory "$projectRoot\core\widgets\common"
Create-Directory "$projectRoot\core\widgets\dialogs"
Create-Directory "$projectRoot\core\widgets\forms"
Create-Directory "$projectRoot\core\widgets\animations"

# Data layer
Create-Directory "$projectRoot\data\datasources\local"
Create-Directory "$projectRoot\data\datasources\remote"
Create-Directory "$projectRoot\data\models\movie"
Create-Directory "$projectRoot\data\models\auth"
Create-Directory "$projectRoot\data\models\favorites"
Create-Directory "$projectRoot\data\models\search"
Create-Directory "$projectRoot\data\repositories"

# Domain layer
Create-Directory "$projectRoot\domain\entities"
Create-Directory "$projectRoot\domain\repositories"
Create-Directory "$projectRoot\domain\usecases\movie"
Create-Directory "$projectRoot\domain\usecases\auth"
Create-Directory "$projectRoot\domain\usecases\favorites"
Create-Directory "$projectRoot\domain\usecases\settings"

# Presentation layer
Create-Directory "$projectRoot\presentation\blocs\movie"
Create-Directory "$projectRoot\presentation\blocs\auth"
Create-Directory "$projectRoot\presentation\blocs\favorites"
Create-Directory "$projectRoot\presentation\blocs\search"
Create-Directory "$projectRoot\presentation\blocs\settings"
Create-Directory "$projectRoot\presentation\cubits"
Create-Directory "$projectRoot\presentation\pages\auth\login"
Create-Directory "$projectRoot\presentation\pages\auth\register"
Create-Directory "$projectRoot\presentation\pages\auth\forgot_password"
Create-Directory "$projectRoot\presentation\pages\main"
Create-Directory "$projectRoot\presentation\pages\home\widgets"
Create-Directory "$projectRoot\presentation\pages\home\viewmodels"
Create-Directory "$projectRoot\presentation\pages\movie\movie_list\widgets"
Create-Directory "$projectRoot\presentation\pages\movie\movie_details\widgets"
Create-Directory "$projectRoot\presentation\pages\search\widgets"
Create-Directory "$projectRoot\presentation\pages\search\viewmodels"
Create-Directory "$projectRoot\presentation\pages\favorites\widgets"
Create-Directory "$projectRoot\presentation\pages\profile\settings"
Create-Directory "$projectRoot\presentation\pages\profile\widgets"
Create-Directory "$projectRoot\presentation\pages\splash"
Create-Directory "$projectRoot\presentation\widgets\movie"
Create-Directory "$projectRoot\presentation\widgets\custom"
Create-Directory "$projectRoot\presentation\widgets\layout"
Create-Directory "$projectRoot\presentation\animations\page_transitions"
Create-Directory "$projectRoot\presentation\animations\custom_animations"
Create-Directory "$projectRoot\presentation\viewmodels"

Write-Host "✅ Структура папок створена успішно!" -ForegroundColor Green