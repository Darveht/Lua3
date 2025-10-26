-- Roogle_Functions.LocalScript (2 de 3)
-- Este script define TODAS las funciones y lógica de la aplicación.

-- ESPERAR a que Core termine de cargar completamente
repeat task.wait(0.1) until _G.RoogleCoreLoaded and _G.RoogleClient
print("⏳ Core detectado, iniciando Functions...")
local R = _G.RoogleClient

-- ========== FUNCIONES ==========

R.previousView = "home"

-- DECLARAR FUNCIONES QUE SE LLAMAN PRIMERO
R.loadHomeSections = function()
        -- Limpiar secciones anteriores
        for _, child in ipairs(R.homeSectionsContainer:GetChildren()) do
                if child:IsA("Frame") then
                        child:Destroy()
                end
        end

        local success, articles = pcall(function()
                return R.getArticlesEvent:InvokeServer("")
        end)

        if not success or not articles then
                return
        end

        -- Filtrar artículos del sistema
        local systemArticles = {}
        local userArticles = {}

        for _, article in ipairs(articles) do
                if article.author == "Sistema" then
                        table.insert(systemArticles, article)
                else
                        table.insert(userArticles, article)
                end
        end

        -- Sección 1: Creadores Destacados
        if R.createFeaturedCreators then
                R.createFeaturedCreators(R.homeSectionsContainer, 1)
        end

        -- Sección 2: Músicas Destacadas (primeras 10 aprobadas)
        task.spawn(function()
                local success, musicList = pcall(function()
                        return R.getMusicEvent:InvokeServer()
                end)
                if success and musicList and #musicList > 0 then
                        local featuredMusic = {}
                        for i = 1, math.min(10, #musicList) do
                                table.insert(featuredMusic, musicList[i])
                        end
                        if R.createMusicHomeSection then
                                R.createMusicHomeSection("🎵 Músicas Destacadas", featuredMusic, R.homeSectionsContainer, 2)
                        end
                end
        end)

        -- Sección 3: Músicas de Pago
        task.spawn(function()
                local success, musicList = pcall(function()
                        return R.getMusicEvent:InvokeServer()
                end)
                if success and musicList then
                        local paidMusic = {}
                        for _, music in ipairs(musicList) do
                                if music.price and music.price > 0 then
                                        table.insert(paidMusic, music)
                                end
                        end
                        if #paidMusic > 0 and R.createMusicHomeSection then
                                R.createMusicHomeSection("💰 Músicas de Pago", paidMusic, R.homeSectionsContainer, 3)
                        end
                end
        end)

        -- Sección 4: Artículos Destacados (del sistema)
        if #systemArticles > 0 and R.createHomeSection then
                R.createHomeSection("⭐ Artículos Destacados", systemArticles, R.homeSectionsContainer, 4)
        end

        -- Sección 5: Artículos Nuevos (últimos 5)
        local newArticles = {}
        for i = 1, math.min(5, #userArticles) do
                table.insert(newArticles, userArticles[i])
        end
        if #newArticles > 0 and R.createHomeSection then
                R.createHomeSection("🆕 Artículos Nuevos", newArticles, R.homeSectionsContainer, 5)
        end

        -- Sección 6: Artículos Recientes
        if #userArticles > 5 then
                local recentArticles = {}
                for i = 6, math.min(15, #userArticles) do
                        table.insert(recentArticles, userArticles[i])
                end
                if #recentArticles > 0 and R.createHomeSection then
                        R.createHomeSection("📚 Artículos Recientes", recentArticles, R.homeSectionsContainer, 6)
                end
        end

        task.wait(0.1)
        R.homeSectionsContainer.CanvasSize = UDim2.new(0, 0, 0, R.homeSectionsLayout.AbsoluteContentSize.Y + 30)
end

R.setInterfaceView = function(viewName)
        R.previousView = (R.centerContainer.Visible and "home") or (R.resultsFrame.Visible and "results") or (R.articleViewFrame.Visible and "article") or (R.profileFrame.Visible and "profile") or R.previousView

        R.centerContainer.Visible = (viewName == "home")
        R.homeSectionsContainer.Visible = (viewName == "home")
        R.resultsFrame.Visible = (viewName == "results")
        R.articleViewFrame.Visible = (viewName == "article")
        R.profileFrame.Visible = (viewName == "profile")
        R.creatorPanel.Visible = (viewName == "creator")
        R.settingsPanel.Visible = (viewName == "settings")
        R.termsPanel.Visible = (viewName == "terms")
        if R.adminPanel then
                R.adminPanel.Visible = (viewName == "admin")
        end

        if viewName == "home" then
                R.loadHomeSections()
        end
end

-- Función para crear insignia de verificación (PALOMITA ✓)
R.createVerifiedBadge = function()
        local badgeContainer = Instance.new("Frame")
        badgeContainer.Name = "VerifiedBadge"
        badgeContainer.Size = UDim2.new(0, 20, 0, 20)
        badgeContainer.BackgroundColor3 = Color3.fromRGB(29, 161, 242)
        badgeContainer.BorderSizePixel = 0

        local badgeCorner = Instance.new("UICorner")
        badgeCorner.CornerRadius = UDim.new(1, 0)
        badgeCorner.Parent = badgeContainer

        local checkmark = Instance.new("TextLabel")
        checkmark.Size = UDim2.new(1, 0, 1, 0)
        checkmark.BackgroundTransparency = 1
        checkmark.Text = "✓"
        checkmark.Font = Enum.Font.GothamBold
        checkmark.TextSize = 14
        checkmark.TextColor3 = Color3.fromRGB(255, 255, 255)
        checkmark.Parent = badgeContainer

        return badgeContainer
end

-- Función para mostrar perfil de usuario
R.showUserProfile = function(userId)
        R.loadingPanel.Visible = true
        R.loadingLabel.Text = "Cargando perfil..."

        local success, profileData = pcall(function()
                return R.getUserProfileEvent:InvokeServer(userId)
        end)

        R.loadingPanel.Visible = false

        if not success or not profileData then
                warn("No se pudo cargar el perfil del usuario")
                return
        end

        -- Limpiar perfil anterior
        for _, child in ipairs(R.profileFrame:GetChildren()) do
                if not child:IsA("UIListLayout") and not child:IsA("UIPadding") and child.Name ~= "ProfileBackButton" then
                        child:Destroy()
                end
        end

        local userInfo = profileData.userInfo
        local articles = profileData.articles

        -- Contenedor de información del usuario
        local userInfoContainer = Instance.new("Frame")
        userInfoContainer.Size = UDim2.new(1, 0, 0, 230)
        userInfoContainer.BackgroundColor3 = Color3.fromRGB(250, 250, 250)
        userInfoContainer.BorderSizePixel = 0
        userInfoContainer.LayoutOrder = 2
        userInfoContainer.Parent = R.profileFrame

        local userInfoCorner = Instance.new("UICorner")
        userInfoCorner.CornerRadius = UDim.new(0, 15)
        userInfoCorner.Parent = userInfoContainer

        local userInfoLayout = Instance.new("UIListLayout")
        userInfoLayout.SortOrder = Enum.SortOrder.LayoutOrder
        userInfoLayout.Padding = UDim.new(0, 12)
        userInfoLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        userInfoLayout.Parent = userInfoContainer

        local userInfoPadding = Instance.new("UIPadding")
        userInfoPadding.PaddingLeft = UDim.new(0, 20)
        userInfoPadding.PaddingRight = UDim.new(0, 20)
        userInfoPadding.PaddingTop = UDim.new(0, 20)
        userInfoPadding.PaddingBottom = UDim.new(0, 20)
        userInfoPadding.Parent = userInfoContainer

        -- Foto de perfil
        local profileImage = Instance.new("ImageLabel")
        profileImage.Size = UDim2.new(0, 100, 0, 100)
        profileImage.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
        profileImage.Image = userInfo.thumbnail
        profileImage.LayoutOrder = 1
        profileImage.Parent = userInfoContainer

        local profileImageCorner = Instance.new("UICorner")
        profileImageCorner.CornerRadius = UDim.new(1, 0)
        profileImageCorner.Parent = profileImage

        -- Nombre de usuario con insignia (INSIGNIA AL LADO DEL NOMBRE)
        local usernameContainer = Instance.new("Frame")
        usernameContainer.Size = UDim2.new(1, 0, 0, 30)
        usernameContainer.BackgroundTransparency = 1
        usernameContainer.LayoutOrder = 2
        usernameContainer.Parent = userInfoContainer

        local usernameLayout = Instance.new("UIListLayout")
        usernameLayout.FillDirection = Enum.FillDirection.Horizontal
        usernameLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        usernameLayout.VerticalAlignment = Enum.VerticalAlignment.Center
        usernameLayout.Padding = UDim.new(0, 6)
        usernameLayout.Parent = usernameContainer

        local usernameLabel = Instance.new("TextLabel")
        usernameLabel.Size = UDim2.new(0, 0, 0, 30)
        usernameLabel.AutomaticSize = Enum.AutomaticSize.X
        usernameLabel.BackgroundTransparency = 1
        usernameLabel.Text = userInfo.username
        usernameLabel.Font = Enum.Font.GothamBold
        usernameLabel.TextSize = 24
        usernameLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
        usernameLabel.Parent = usernameContainer

        -- INSIGNIA AL LADO DEL NOMBRE (NO DE LA FECHA)
        if userInfo.verified then
                local verifiedBadge = R.createVerifiedBadge()
                verifiedBadge.Parent = usernameContainer
        end

        -- Estadísticas (seguidores, siguiendo, artículos)
        local statsContainer = Instance.new("Frame")
        statsContainer.Size = UDim2.new(1, 0, 0, 25)
        statsContainer.BackgroundTransparency = 1
        statsContainer.LayoutOrder = 3
        statsContainer.Parent = userInfoContainer

        local statsLayout = Instance.new("UIListLayout")
        statsLayout.FillDirection = Enum.FillDirection.Horizontal
        statsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        statsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
        statsLayout.Padding = UDim.new(0, 20)
        statsLayout.Parent = statsContainer

        local followersLabel = Instance.new("TextLabel")
        followersLabel.Name = "FollowersLabel"
        followersLabel.Size = UDim2.new(0, 0, 1, 0)
        followersLabel.AutomaticSize = Enum.AutomaticSize.X
        followersLabel.BackgroundTransparency = 1
        followersLabel.Font = Enum.Font.Gotham
        followersLabel.TextSize = 16
        followersLabel.TextColor3 = Color3.fromRGB(100, 100, 100)
        followersLabel.Parent = statsContainer

        local followingLabel = Instance.new("TextLabel")
        followingLabel.Size = UDim2.new(0, 0, 1, 0)
        followingLabel.AutomaticSize = Enum.AutomaticSize.X
        followingLabel.BackgroundTransparency = 1
        followingLabel.Font = Enum.Font.Gotham
        followingLabel.TextSize = 16
        followingLabel.TextColor3 = Color3.fromRGB(100, 100, 100)
        followingLabel.Parent = statsContainer

        local articlesLabel = Instance.new("TextLabel")
        articlesLabel.Size = UDim2.new(0, 0, 1, 0)
        articlesLabel.AutomaticSize = Enum.AutomaticSize.X
        articlesLabel.BackgroundTransparency = 1
        articlesLabel.Text = string.format("%d Artículos", #articles)
        articlesLabel.Font = Enum.Font.Gotham
        articlesLabel.TextSize = 16
        articlesLabel.TextColor3 = Color3.fromRGB(100, 100, 100)
        articlesLabel.Parent = statsContainer

        -- DETECTOR: Si es el usuario Sistema (userId = 1), obtener estadísticas reales de Roblox
        if userId == 1 then
                followersLabel.Text = "Cargando..."
                followingLabel.Text = "Cargando..."

                task.spawn(function()
                        local success, robloxStats = pcall(function()
                                return R.getRobloxStatsEvent:InvokeServer(userId)
                        end)

                        if success and robloxStats then
                                followersLabel.Text = string.format("%s Seguidores", R.formatLargeNumber(robloxStats.followers))
                                followingLabel.Text = string.format("%s Siguiendo", R.formatLargeNumber(robloxStats.following))
                        else
                                -- Si falla, usar valores de la base de datos
                                followersLabel.Text = string.format("%d Seguidores", profileData.followersCount)
                                followingLabel.Text = string.format("%d Siguiendo", profileData.followingCount)
                        end
                end)
        else
                -- Para usuarios normales, usar valores de la base de datos
                followersLabel.Text = string.format("%d Seguidores", profileData.followersCount)
                followingLabel.Text = string.format("%d Siguiendo", profileData.followingCount)
        end

        -- BOTÓN SEGUIR ANTES QUE ARTÍCULOS (solo si no es el propio perfil)
        if userId ~= R.player.UserId then
                local followButton = Instance.new("TextButton")
                followButton.Name = "FollowButton"
                followButton.Size = UDim2.new(0, 150, 0, 40)
                followButton.BackgroundColor3 = profileData.isFollowing and Color3.fromRGB(200, 200, 200) or Color3.fromRGB(66, 133, 244)
                followButton.Text = profileData.isFollowing and "Dejar de Seguir" or "Seguir"
                followButton.Font = Enum.Font.GothamBold
                followButton.TextSize = 16
                followButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                followButton.BorderSizePixel = 0
                followButton.LayoutOrder = 4
                followButton.Parent = userInfoContainer

                local followCorner = Instance.new("UICorner")
                followCorner.CornerRadius = UDim.new(0, 10)
                followCorner.Parent = followButton

                followButton.MouseButton1Click:Connect(function()
                        local success, result
                        if profileData.isFollowing then
                                success, result = pcall(function()
                                        return R.unfollowUserEvent:InvokeServer(userId)
                                end)
                                if success and result then
                                        followButton.Text = "Seguir"
                                        followButton.BackgroundColor3 = Color3.fromRGB(66, 133, 244)
                                        profileData.isFollowing = false
                                        profileData.followersCount = profileData.followersCount - 1
                                        followersLabel.Text = string.format("%d Seguidores", profileData.followersCount)
                                end
                        else
                                success, result = pcall(function()
                                        return R.followUserEvent:InvokeServer(userId)
                                end)
                                if success and result then
                                        followButton.Text = "Dejar de Seguir"
                                        followButton.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
                                        profileData.isFollowing = true
                                        profileData.followersCount = profileData.followersCount + 1
                                        followersLabel.Text = string.format("%d Seguidores", profileData.followersCount)
                                end
                        end
                end)
        end

        -- Título de artículos DESPUÉS DEL BOTÓN SEGUIR
        local articlesTitle = Instance.new("TextLabel")
        articlesTitle.Size = UDim2.new(1, 0, 0, 30)
        articlesTitle.BackgroundTransparency = 1
        articlesTitle.Text = "📚 Artículos Publicados"
        articlesTitle.Font = Enum.Font.GothamBold
        articlesTitle.TextSize = 20
        articlesTitle.TextColor3 = Color3.fromRGB(0, 0, 0)
        articlesTitle.TextXAlignment = Enum.TextXAlignment.Left
        articlesTitle.LayoutOrder = 3
        articlesTitle.Parent = R.profileFrame

        -- Mostrar artículos del usuario
        if #articles == 0 then
                local noArticlesLabel = Instance.new("TextLabel")
                noArticlesLabel.Size = UDim2.new(1, 0, 0, 50)
                noArticlesLabel.BackgroundTransparency = 1
                noArticlesLabel.Text = "Este usuario aún no ha publicado artículos"
                noArticlesLabel.Font = Enum.Font.Gotham
                noArticlesLabel.TextSize = 16
                noArticlesLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
                noArticlesLabel.LayoutOrder = 4
                noArticlesLabel.Parent = R.profileFrame
        else
                for i, article in ipairs(articles) do
                        local articleCard = Instance.new("Frame")
                        articleCard.Size = UDim2.new(1, 0, 0, 120)
                        articleCard.BackgroundColor3 = Color3.fromRGB(250, 250, 250)
                        articleCard.BorderSizePixel = 0
                        articleCard.LayoutOrder = 3 + i
                        articleCard.Parent = R.profileFrame

                        local articleCardCorner = Instance.new("UICorner")
                        articleCardCorner.CornerRadius = UDim.new(0, 10)
                        articleCardCorner.Parent = articleCard

                        local articleCardLayout = Instance.new("UIListLayout")
                        articleCardLayout.SortOrder = Enum.SortOrder.LayoutOrder
                        articleCardLayout.Padding = UDim.new(0, 8)
                        articleCardLayout.Parent = articleCard

                        local articleCardPadding = Instance.new("UIPadding")
                        articleCardPadding.PaddingLeft = UDim.new(0, 15)
                        articleCardPadding.PaddingRight = UDim.new(0, 15)
                        articleCardPadding.PaddingTop = UDim.new(0, 15)
                        articleCardPadding.PaddingBottom = UDim.new(0, 15)
                        articleCardPadding.Parent = articleCard

                        local articleTitleLabel = Instance.new("TextButton")
                        articleTitleLabel.Size = UDim2.new(1, 0, 0, 30)
                        articleTitleLabel.BackgroundTransparency = 1
                        articleTitleLabel.Text = article.title
                        articleTitleLabel.Font = Enum.Font.GothamBold
                        articleTitleLabel.TextSize = 18
                        articleTitleLabel.TextColor3 = Color3.fromRGB(26, 115, 232)
                        articleTitleLabel.TextXAlignment = Enum.TextXAlignment.Left
                        articleTitleLabel.TextWrapped = true
                        articleTitleLabel.LayoutOrder = 1
                        articleTitleLabel.Parent = articleCard

                        articleTitleLabel.MouseButton1Click:Connect(function()
                                R.showArticle(article.id)
                        end)

                        local articleDesc = Instance.new("TextLabel")
                        articleDesc.Size = UDim2.new(1, 0, 0, 40)
                        articleDesc.BackgroundTransparency = 1
                        articleDesc.Text = string.sub(article.description, 1, 100) .. (string.len(article.description) > 100 and "..." or "")
                        articleDesc.Font = Enum.Font.Gotham
                        articleDesc.TextSize = 14
                        articleDesc.TextColor3 = Color3.fromRGB(100, 100, 100)
                        articleDesc.TextXAlignment = Enum.TextXAlignment.Left
                        articleDesc.TextYAlignment = Enum.TextYAlignment.Top
                        articleDesc.TextWrapped = true
                        articleDesc.LayoutOrder = 2
                        articleDesc.Parent = articleCard

                        local articleDate = Instance.new("TextLabel")
                        articleDate.Size = UDim2.new(1, 0, 0, 18)
                        articleDate.BackgroundTransparency = 1
                        articleDate.Text = article.dateCreated
                        articleDate.Font = Enum.Font.Gotham
                        articleDate.TextSize = 12
                        articleDate.TextColor3 = Color3.fromRGB(150, 150, 150)
                        articleDate.TextXAlignment = Enum.TextXAlignment.Left
                        articleDate.LayoutOrder = 3
                        articleDate.Parent = articleCard
                end
        end

        -- Actualizar CanvasSize
        task.wait(0.1)
        R.profileFrame.CanvasSize = UDim2.new(0, 0, 0, R.profileLayout.AbsoluteContentSize.Y + 60)

        R.setInterfaceView("profile")
end

R.showArticle = function(articleId)
        local article = R.getArticleByIdEvent:InvokeServer(articleId)

        if not article then
                warn("Artículo no encontrado")
                return
        end

        for _, child in ipairs(R.articleViewFrame:GetChildren()) do
                if child:IsA("Frame") or child:IsA("TextLabel") or child:IsA("TextButton") then
                        if child.Name ~= "BackButton" then
                                child:Destroy()
                        end
                end
        end

        -- Título del artículo
        local articleTitle = Instance.new("TextLabel")
        articleTitle.Size = UDim2.new(1, 0, 0, 0)
        articleTitle.AutomaticSize = Enum.AutomaticSize.Y
        articleTitle.BackgroundTransparency = 1
        articleTitle.Text = article.title
        articleTitle.Font = Enum.Font.GothamBold
        articleTitle.TextSize = 36
        articleTitle.TextColor3 = Color3.fromRGB(0, 0, 0)
        articleTitle.TextXAlignment = Enum.TextXAlignment.Left
        articleTitle.TextWrapped = true
        articleTitle.LayoutOrder = 2
        articleTitle.Parent = R.articleViewFrame

        -- Categoría dentro del artículo (SIN EMOJI)
        local categoryLabel = Instance.new("TextLabel")
        categoryLabel.Size = UDim2.new(1, 0, 0, 20)
        categoryLabel.BackgroundTransparency = 1
        categoryLabel.Text = article.category or "General"
        categoryLabel.Font = Enum.Font.GothamBold
        categoryLabel.TextSize = 14
        categoryLabel.TextColor3 = Color3.fromRGB(66, 133, 244)
        categoryLabel.TextXAlignment = Enum.TextXAlignment.Left
        categoryLabel.LayoutOrder = 3
        categoryLabel.Parent = R.articleViewFrame

        -- Información del autor (clickeable)
        local authorContainer = Instance.new("TextButton")
        authorContainer.Size = UDim2.new(1, 0, 0, 60)
        authorContainer.BackgroundColor3 = Color3.fromRGB(250, 250, 250)
        authorContainer.BorderSizePixel = 0
        authorContainer.LayoutOrder = 4
        authorContainer.AutoButtonColor = false
        authorContainer.Text = ""
        authorContainer.Parent = R.articleViewFrame

        local authorCorner = Instance.new("UICorner")
        authorCorner.CornerRadius = UDim.new(0, 10)
        authorCorner.Parent = authorContainer

        authorContainer.MouseButton1Click:Connect(function()
                R.showUserProfile(article.authorId)
        end)

        -- Foto del autor
        local authorImage = Instance.new("ImageLabel")
        authorImage.Size = UDim2.new(0, 45, 0, 45)
        authorImage.Position = UDim2.new(0, 10, 0.5, -22.5)
        authorImage.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
        authorImage.Image = article.authorThumbnail
        authorImage.Parent = authorContainer

        local authorImageCorner = Instance.new("UICorner")
        authorImageCorner.CornerRadius = UDim.new(1, 0)
        authorImageCorner.Parent = authorImage

        -- Información del autor y fecha
        local authorInfoContainer = Instance.new("Frame")
        authorInfoContainer.Size = UDim2.new(1, -70, 1, 0)
        authorInfoContainer.Position = UDim2.new(0, 65, 0, 0)
        authorInfoContainer.BackgroundTransparency = 1
        authorInfoContainer.Parent = authorContainer

        local authorInfoLayout = Instance.new("UIListLayout")
        authorInfoLayout.SortOrder = Enum.SortOrder.LayoutOrder
        authorInfoLayout.Padding = UDim.new(0, 4)
        authorInfoLayout.VerticalAlignment = Enum.VerticalAlignment.Center
        authorInfoLayout.Parent = authorInfoContainer

        -- Nombre del autor con insignia (INSIGNIA AL LADO DEL NOMBRE)
        local authorNameContainer = Instance.new("Frame")
        authorNameContainer.Size = UDim2.new(1, 0, 0, 20)
        authorNameContainer.BackgroundTransparency = 1
        authorNameContainer.LayoutOrder = 1
        authorNameContainer.Parent = authorInfoContainer

        local authorNameLayout = Instance.new("UIListLayout")
        authorNameLayout.FillDirection = Enum.FillDirection.Horizontal
        authorNameLayout.VerticalAlignment = Enum.VerticalAlignment.Center
        authorNameLayout.Padding = UDim.new(0, 5)
        authorNameLayout.Parent = authorNameContainer

        local authorName = Instance.new("TextLabel")
        authorName.Size = UDim2.new(0, 0, 0, 20)
        authorName.AutomaticSize = Enum.AutomaticSize.X
        authorName.BackgroundTransparency = 1
        authorName.Text = "Por " .. article.author
        authorName.Font = Enum.Font.GothamBold
        authorName.TextSize = 16
        authorName.TextColor3 = Color3.fromRGB(50, 50, 50)
        authorName.TextXAlignment = Enum.TextXAlignment.Left
        authorName.Parent = authorNameContainer

        -- INSIGNIA AL LADO DEL NOMBRE (NO DE LA FECHA)
        if article.verified then
                local verifiedBadge = R.createVerifiedBadge()
                verifiedBadge.Parent = authorNameContainer
        end

        -- FECHA SIN INSIGNIA
        local articleDate = Instance.new("TextLabel")
        articleDate.Size = UDim2.new(1, 0, 0, 16)
        articleDate.BackgroundTransparency = 1
        articleDate.Text = article.dateCreated
        articleDate.Font = Enum.Font.Gotham
        articleDate.TextSize = 14
        articleDate.TextColor3 = Color3.fromRGB(120, 120, 120)
        articleDate.TextXAlignment = Enum.TextXAlignment.Left
        articleDate.LayoutOrder = 2
        articleDate.Parent = authorInfoContainer

        -- Línea separadora
        local separator = Instance.new("Frame")
        separator.Size = UDim2.new(1, 0, 0, 2)
        separator.BackgroundColor3 = Color3.fromRGB(230, 230, 230)
        separator.BorderSizePixel = 0
        separator.LayoutOrder = 5
        separator.Parent = R.articleViewFrame

        -- Contenido del artículo (SIN LÍMITE DE TAMAÑO)
        local articleContent = Instance.new("TextLabel")
        articleContent.Size = UDim2.new(1, 0, 0, 0)
        articleContent.AutomaticSize = Enum.AutomaticSize.Y
        articleContent.BackgroundTransparency = 1
        articleContent.Text = article.content
        articleContent.Font = Enum.Font.Gotham
        articleContent.TextSize = 18
        articleContent.TextColor3 = Color3.fromRGB(50, 50, 50)
        articleContent.TextXAlignment = Enum.TextXAlignment.Left
        articleContent.TextYAlignment = Enum.TextYAlignment.Top
        articleContent.TextWrapped = true
        articleContent.LayoutOrder = 6
        articleContent.Parent = R.articleViewFrame

        -- Actualizar CanvasSize para permitir scroll completo
        task.wait(0.1)
        R.articleViewFrame.CanvasSize = UDim2.new(0, 0, 0, R.articleLayout.AbsoluteContentSize.Y + 60)

        R.setInterfaceView("article")
end

-- Función para crear sección de música en inicio (horizontal)
R.createMusicHomeSection = function(title, musicList, parent, layoutOrder)
        if #musicList == 0 then return end

        local sectionContainer = Instance.new("Frame")
        sectionContainer.Size = UDim2.new(1, 0, 0, 240)
        sectionContainer.BackgroundTransparency = 1
        sectionContainer.LayoutOrder = layoutOrder
        sectionContainer.Parent = parent

        local sectionLayout = Instance.new("UIListLayout")
        sectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
        sectionLayout.Padding = UDim.new(0, 10)
        sectionLayout.Parent = sectionContainer

        -- Título de la sección
        local sectionTitle = Instance.new("TextLabel")
        sectionTitle.Size = UDim2.new(1, 0, 0, 30)
        sectionTitle.BackgroundTransparency = 1
        sectionTitle.Text = title
        sectionTitle.Font = Enum.Font.GothamBold
        sectionTitle.TextSize = 22
        sectionTitle.TextColor3 = Color3.fromRGB(0, 0, 0)
        sectionTitle.TextXAlignment = Enum.TextXAlignment.Left
        sectionTitle.LayoutOrder = 1
        sectionTitle.Parent = sectionContainer

        -- Scroll horizontal de música
        local musicScroll = Instance.new("ScrollingFrame")
        musicScroll.Size = UDim2.new(1, 0, 0, 200)
        musicScroll.BackgroundTransparency = 1
        musicScroll.BorderSizePixel = 0
        musicScroll.ScrollBarThickness = 4
        musicScroll.ScrollBarImageColor3 = Color3.fromRGB(200, 200, 200)
        musicScroll.ScrollingDirection = Enum.ScrollingDirection.X
        musicScroll.CanvasSize = UDim2.new(0, #musicList * 320, 0, 0)
        musicScroll.LayoutOrder = 2
        musicScroll.Parent = sectionContainer

        local musicLayout = Instance.new("UIListLayout")
        musicLayout.FillDirection = Enum.FillDirection.Horizontal
        musicLayout.Padding = UDim.new(0, 15)
        musicLayout.Parent = musicScroll

        -- Crear tarjetas de música
        for i, music in ipairs(musicList) do
                local musicCard = Instance.new("TextButton")
                musicCard.Size = UDim2.new(0, 300, 0, 170)
                musicCard.BackgroundColor3 = Color3.fromRGB(250, 250, 250)
                musicCard.BorderSizePixel = 0
                musicCard.AutoButtonColor = false
                musicCard.Text = ""
                musicCard.LayoutOrder = i
                musicCard.Parent = musicScroll

                local cardCorner = Instance.new("UICorner")
                cardCorner.CornerRadius = UDim.new(0, 10)
                cardCorner.Parent = musicCard

                local cardLayout = Instance.new("UIListLayout")
                cardLayout.SortOrder = Enum.SortOrder.LayoutOrder
                cardLayout.Padding = UDim.new(0, 8)
                cardLayout.Parent = musicCard

                local cardPadding = Instance.new("UIPadding")
                cardPadding.PaddingLeft = UDim.new(0, 15)
                cardPadding.PaddingRight = UDim.new(0, 15)
                cardPadding.PaddingTop = UDim.new(0, 15)
                cardPadding.PaddingBottom = UDim.new(0, 15)
                cardPadding.Parent = musicCard

                -- Título con etiqueta de precio
                local titleContainer = Instance.new("Frame")
                titleContainer.Size = UDim2.new(1, 0, 0, 30)
                titleContainer.BackgroundTransparency = 1
                titleContainer.LayoutOrder = 1
                titleContainer.Parent = musicCard

                local titleLayout = Instance.new("UIListLayout")
                titleLayout.SortOrder = Enum.SortOrder.LayoutOrder
                titleLayout.Padding = UDim.new(0, 5)
                titleLayout.Parent = titleContainer

                local cardTitle = Instance.new("TextLabel")
                cardTitle.Size = UDim2.new(1, 0, 0, 0)
                cardTitle.AutomaticSize = Enum.AutomaticSize.Y
                cardTitle.BackgroundTransparency = 1
                cardTitle.Text = "🎵 " .. music.name
                cardTitle.Font = Enum.Font.GothamBold
                cardTitle.TextSize = 18
                cardTitle.TextColor3 = Color3.fromRGB(255, 87, 34)
                cardTitle.TextXAlignment = Enum.TextXAlignment.Left
                cardTitle.TextWrapped = true
                cardTitle.LayoutOrder = 1
                cardTitle.Parent = titleContainer

                -- Etiqueta de precio verde
                if music.price and music.price > 0 then
                        local priceTag = Instance.new("Frame")
                        priceTag.Size = UDim2.new(0, 80, 0, 22)
                        priceTag.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
                        priceTag.LayoutOrder = 2
                        priceTag.Parent = titleContainer

                        local priceCorner = Instance.new("UICorner")
                        priceCorner.CornerRadius = UDim.new(0, 6)
                        priceCorner.Parent = priceTag

                        local priceLabel = Instance.new("TextLabel")
                        priceLabel.Size = UDim2.new(1, 0, 1, 0)
                        priceLabel.BackgroundTransparency = 1
                        priceLabel.Text = music.price .. " R$"
                        priceLabel.Font = Enum.Font.GothamBold
                        priceLabel.TextSize = 13
                        priceLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                        priceLabel.Parent = priceTag
                end

                -- Categoría
                local categoryLabel = Instance.new("TextLabel")
                categoryLabel.Size = UDim2.new(1, 0, 0, 18)
                categoryLabel.BackgroundTransparency = 1
                categoryLabel.Text = music.category
                categoryLabel.Font = Enum.Font.Gotham
                categoryLabel.TextSize = 14
                categoryLabel.TextColor3 = Color3.fromRGB(100, 100, 100)
                categoryLabel.TextXAlignment = Enum.TextXAlignment.Left
                categoryLabel.LayoutOrder = 2
                categoryLabel.Parent = musicCard

                -- Autor
                local authorLabel = Instance.new("TextLabel")
                authorLabel.Size = UDim2.new(1, 0, 0, 18)
                authorLabel.BackgroundTransparency = 1
                authorLabel.Text = "Por " .. music.author
                authorLabel.Font = Enum.Font.Gotham
                authorLabel.TextSize = 13
                authorLabel.TextColor3 = Color3.fromRGB(120, 120, 120)
                authorLabel.TextXAlignment = Enum.TextXAlignment.Left
                authorLabel.LayoutOrder = 3
                authorLabel.Parent = musicCard

                musicCard.MouseButton1Click:Connect(function()
                        if music.price and music.price > 0 then
                                local success, result = pcall(function()
                                        return R.purchaseMusicEvent:InvokeServer(music.id)
                                end)
                                if success and result then
                                        R.openMusicPlayer(music)
                                end
                        else
                                R.openMusicPlayer(music)
                        end
                end)
        end
end

-- Función para crear sección de artículos (horizontal)
R.createHomeSection = function(title, articles, parent, layoutOrder)
        if #articles == 0 then return end

        local sectionContainer = Instance.new("Frame")
        sectionContainer.Size = UDim2.new(1, 0, 0, 240)
        sectionContainer.BackgroundTransparency = 1
        sectionContainer.LayoutOrder = layoutOrder
        sectionContainer.Parent = parent

        local sectionLayout = Instance.new("UIListLayout")
        sectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
        sectionLayout.Padding = UDim.new(0, 10)
        sectionLayout.Parent = sectionContainer

        -- Título de la sección
        local sectionTitle = Instance.new("TextLabel")
        sectionTitle.Size = UDim2.new(1, 0, 0, 30)
        sectionTitle.BackgroundTransparency = 1
        sectionTitle.Text = title
        sectionTitle.Font = Enum.Font.GothamBold
        sectionTitle.TextSize = 22
        sectionTitle.TextColor3 = Color3.fromRGB(0, 0, 0)
        sectionTitle.TextXAlignment = Enum.TextXAlignment.Left
        sectionTitle.LayoutOrder = 1
        sectionTitle.Parent = sectionContainer

        -- Scroll horizontal de artículos
        local articlesScroll = Instance.new("ScrollingFrame")
        articlesScroll.Size = UDim2.new(1, 0, 0, 200)
        articlesScroll.BackgroundTransparency = 1
        articlesScroll.BorderSizePixel = 0
        articlesScroll.ScrollBarThickness = 4
        articlesScroll.ScrollBarImageColor3 = Color3.fromRGB(200, 200, 200)
        articlesScroll.ScrollingDirection = Enum.ScrollingDirection.X
        articlesScroll.CanvasSize = UDim2.new(0, #articles * 320, 0, 0)
        articlesScroll.LayoutOrder = 2
        articlesScroll.Parent = sectionContainer

        local articlesLayout = Instance.new("UIListLayout")
        articlesLayout.FillDirection = Enum.FillDirection.Horizontal
        articlesLayout.Padding = UDim.new(0, 15)
        articlesLayout.Parent = articlesScroll

        -- Crear tarjetas de artículos
        for i, article in ipairs(articles) do
                local articleCard = Instance.new("TextButton")
                articleCard.Size = UDim2.new(0, 300, 0, 170)
                articleCard.BackgroundColor3 = Color3.fromRGB(250, 250, 250)
                articleCard.BorderSizePixel = 0
                articleCard.AutoButtonColor = false
                articleCard.Text = ""
                articleCard.LayoutOrder = i
                articleCard.Parent = articlesScroll

                local cardCorner = Instance.new("UICorner")
                cardCorner.CornerRadius = UDim.new(0, 10)
                cardCorner.Parent = articleCard

                local cardLayout = Instance.new("UIListLayout")
                cardLayout.SortOrder = Enum.SortOrder.LayoutOrder
                cardLayout.Padding = UDim.new(0, 8)
                cardLayout.Parent = articleCard

                local cardPadding = Instance.new("UIPadding")
                cardPadding.PaddingLeft = UDim.new(0, 15)
                cardPadding.PaddingRight = UDim.new(0, 15)
                cardPadding.PaddingTop = UDim.new(0, 15)
                cardPadding.PaddingBottom = UDim.new(0, 15)
                cardPadding.Parent = articleCard

                -- Título
                local cardTitle = Instance.new("TextLabel")
                cardTitle.Size = UDim2.new(1, 0, 0, 50)
                cardTitle.BackgroundTransparency = 1
                cardTitle.Text = article.title
                cardTitle.Font = Enum.Font.GothamBold
                cardTitle.TextSize = 18
                cardTitle.TextColor3 = Color3.fromRGB(26, 115, 232)
                cardTitle.TextXAlignment = Enum.TextXAlignment.Left
                cardTitle.TextYAlignment = Enum.TextYAlignment.Top
                cardTitle.TextWrapped = true
                cardTitle.LayoutOrder = 1
                cardTitle.Parent = articleCard

                -- Descripción
                local cardDesc = Instance.new("TextLabel")
                cardDesc.Size = UDim2.new(1, 0, 0, 60)
                cardDesc.BackgroundTransparency = 1
                cardDesc.Text = string.sub(article.description, 1, 100) .. "..."
                cardDesc.Font = Enum.Font.Gotham
                cardDesc.TextSize = 14
                cardDesc.TextColor3 = Color3.fromRGB(100, 100, 100)
                cardDesc.TextXAlignment = Enum.TextXAlignment.Left
                cardDesc.TextYAlignment = Enum.TextYAlignment.Top
                cardDesc.TextWrapped = true
                cardDesc.LayoutOrder = 2
                cardDesc.Parent = articleCard

                -- Categoría
                local categoryLabel = Instance.new("TextLabel")
                categoryLabel.Size = UDim2.new(1, 0, 0, 18)
                categoryLabel.BackgroundTransparency = 1
                categoryLabel.Text = article.category or "General"
                categoryLabel.Font = Enum.Font.Gotham
                categoryLabel.TextSize = 12
                categoryLabel.TextColor3 = Color3.fromRGB(66, 133, 244)
                categoryLabel.TextXAlignment = Enum.TextXAlignment.Left
                categoryLabel.LayoutOrder = 3
                categoryLabel.Parent = articleCard

                -- Autor con insignia
                local authorContainer = Instance.new("Frame")
                authorContainer.Size = UDim2.new(1, 0, 0, 20)
                authorContainer.BackgroundTransparency = 1
                authorContainer.LayoutOrder = 4
                authorContainer.Parent = articleCard

                local authorLayout = Instance.new("UIListLayout")
                authorLayout.FillDirection = Enum.FillDirection.Horizontal
                authorLayout.VerticalAlignment = Enum.VerticalAlignment.Center
                authorLayout.Padding = UDim.new(0, 5)
                authorLayout.Parent = authorContainer

                local authorText = Instance.new("TextLabel")
                authorText.Size = UDim2.new(0, 0, 0, 18)
                authorText.AutomaticSize = Enum.AutomaticSize.X
                authorText.BackgroundTransparency = 1
                authorText.Text = article.author
                authorText.Font = Enum.Font.Gotham
                authorText.TextSize = 13
                authorText.TextColor3 = Color3.fromRGB(0, 102, 204)
                authorText.Parent = authorContainer

                if article.verified then
                        local badge = R.createVerifiedBadge()
                        badge.Size = UDim2.new(0, 14, 0, 14)
                        badge.Parent = authorContainer
                end

                articleCard.MouseButton1Click:Connect(function()
                        R.showArticle(article.id)
                end)
        end
end

R.createArticleCard = function(article, parent, index)
        local resultCard = Instance.new("Frame")
        resultCard.Size = UDim2.new(1, 0, 0, 150)
        resultCard.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        resultCard.BorderSizePixel = 0
        resultCard.LayoutOrder = index
        resultCard.Parent = parent

        local cardLayout = Instance.new("UIListLayout")
        cardLayout.SortOrder = Enum.SortOrder.LayoutOrder
        cardLayout.Padding = UDim.new(0, 6)
        cardLayout.Parent = resultCard

        local cardPadding = Instance.new("UIPadding")
        cardPadding.PaddingLeft = UDim.new(0, 15)
        cardPadding.PaddingRight = UDim.new(0, 15)
        cardPadding.PaddingTop = UDim.new(0, 15)
        cardPadding.PaddingBottom = UDim.new(0, 15)
        cardPadding.Parent = resultCard

        -- Título clickeable
        local resultTitle = Instance.new("TextButton")
        resultTitle.Size = UDim2.new(1, 0, 0, 28)
        resultTitle.BackgroundTransparency = 1
        resultTitle.Text = article.title
        resultTitle.Font = Enum.Font.GothamBold
        resultTitle.TextSize = 20
        resultTitle.TextColor3 = Color3.fromRGB(26, 115, 232)
        resultTitle.TextXAlignment = Enum.TextXAlignment.Left
        resultTitle.TextWrapped = true
        resultTitle.LayoutOrder = 1
        resultTitle.Parent = resultCard

        resultTitle.MouseButton1Click:Connect(function()
                R.showArticle(article.id)
        end)

        -- Descripción
        local resultDesc = Instance.new("TextLabel")
        resultDesc.Size = UDim2.new(1, 0, 0, 38)
        resultDesc.BackgroundTransparency = 1
        resultDesc.Text = string.sub(article.description, 1, 150) .. (string.len(article.description) > 150 and "..." or "")
        resultDesc.Font = Enum.Font.Gotham
        resultDesc.TextSize = 15
        resultDesc.TextColor3 = Color3.fromRGB(70, 70, 70)
        resultDesc.TextXAlignment = Enum.TextXAlignment.Left
        resultDesc.TextYAlignment = Enum.TextYAlignment.Top
        resultDesc.TextWrapped = true
        resultDesc.LayoutOrder = 2
        resultDesc.Parent = resultCard

        -- Categoría
        local categoryLabel = Instance.new("TextLabel")
        categoryLabel.Size = UDim2.new(1, 0, 0, 18)
        categoryLabel.BackgroundTransparency = 1
        categoryLabel.Text = article.category or "General"
        categoryLabel.Font = Enum.Font.GothamBold
        categoryLabel.TextSize = 13
        categoryLabel.TextColor3 = Color3.fromRGB(66, 133, 244)
        categoryLabel.TextXAlignment = Enum.TextXAlignment.Left
        categoryLabel.LayoutOrder = 3
        categoryLabel.Parent = resultCard

        -- Autor (clickeable) con verificación AL LADO DEL NOMBRE - VERSIÓN CORRECTA
        local authorContainer = Instance.new("Frame")
        authorContainer.Size = UDim2.new(1, 0, 0, 22)
        authorContainer.BackgroundTransparency = 1
        authorContainer.LayoutOrder = 4
        authorContainer.Parent = resultCard

        local authorLayout = Instance.new("UIListLayout")
        authorLayout.FillDirection = Enum.FillDirection.Horizontal
        authorLayout.VerticalAlignment = Enum.VerticalAlignment.Center
        authorLayout.Padding = UDim.new(0, 5)
        authorLayout.Parent = authorContainer

        local authorButton = Instance.new("TextButton")
        authorButton.Size = UDim2.new(0, 0, 0, 18)
        authorButton.AutomaticSize = Enum.AutomaticSize.X
        authorButton.BackgroundTransparency = 1
        authorButton.Text = article.author
        authorButton.Font = Enum.Font.Gotham
        authorButton.TextSize = 14
        authorButton.TextColor3 = Color3.fromRGB(0, 102, 204)
        authorButton.Parent = authorContainer

        -- INSIGNIA AL LADO DEL NOMBRE
        if article.verified then
                local verifiedBadge = R.createVerifiedBadge()
                verifiedBadge.Size = UDim2.new(0, 16, 0, 16)
                verifiedBadge.Parent = authorContainer
        end

        -- FECHA SEPARADA (SIN INSIGNIA)
        local dateText = Instance.new("TextLabel")
        dateText.Size = UDim2.new(0, 0, 0, 18)
        dateText.AutomaticSize = Enum.AutomaticSize.X
        dateText.BackgroundTransparency = 1
        dateText.Text = " • " .. article.dateCreated
        dateText.Font = Enum.Font.Gotham
        dateText.TextSize = 14
        dateText.TextColor3 = Color3.fromRGB(120, 120, 120)
        dateText.Parent = authorContainer

        authorButton.MouseButton1Click:Connect(function()
                R.showUserProfile(article.authorId)
        end)

        -- Línea separadora
        local divider = Instance.new("Frame")
        divider.Size = UDim2.new(1, 0, 0, 1)
        divider.BackgroundColor3 = Color3.fromRGB(230, 230, 230)
        divider.BorderSizePixel = 0
        divider.LayoutOrder = 5
        divider.Parent = resultCard
end

R.loadArticles = function(query)
        for _, child in ipairs(R.resultsScrollFrame:GetChildren()) do
                if child:IsA("Frame") then
                        child:Destroy()
                end
        end

        local success, articles = pcall(function()
                return R.getArticlesEvent:InvokeServer(query)
        end)

        if not success or not articles then
                warn("Error al cargar artículos")
                return
        end

        if #articles == 0 then
                local noResults = Instance.new("TextLabel")
                noResults.Size = UDim2.new(1, 0, 0, 100)
                noResults.BackgroundTransparency = 1
                noResults.Text = query == "" and "No hay artículos disponibles" or "No se encontraron resultados para " .. query
                noResults.Font = Enum.Font.Gotham
                noResults.TextSize = 18
                noResults.TextColor3 = Color3.fromRGB(150, 150, 150)
                noResults.Parent = R.resultsScrollFrame
        else
                for i, article in ipairs(articles) do
                        R.createArticleCard(article, R.resultsScrollFrame, i)
                end
        end

        task.wait(0.1)
        R.resultsScrollFrame.CanvasSize = UDim2.new(0, 0, 0, R.resultsLayout.AbsoluteContentSize.Y + 60)
end

-- Función para abrir reproductor de música
R.openMusicPlayer = function(musicData)
        -- Detener música anterior si existe
        if R.currentSound then
                R.currentSound:Stop()
                R.currentSound:Destroy()
                R.currentSound = nil
        end

        -- Actualizar interfaz
        R.musicPlayerTitle.Text = musicData.name
        R.musicPlayerCategory.Text = musicData.category
        R.currentTimeLabel.Text = "0:00"
        R.totalTimeLabel.Text = "0:00"
        R.musicProgressBar.Size = UDim2.new(0, 0, 1, 0)
        R.playPauseButton.Text = "⏸"

        -- Crear nuevo Sound
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://" .. musicData.audioId
        sound.Volume = 0.5
        sound.Parent = game.SoundService
        R.currentSound = sound

        -- Reproducir automáticamente
        sound:Play()

        -- Cargar el audio
        sound.Loaded:Connect(function()
                local duration = sound.TimeLength
                local minutes = math.floor(duration / 60)
                local seconds = math.floor(duration % 60)
                R.totalTimeLabel.Text = string.format("%d:%02d", minutes, seconds)
        end)

        -- Actualizar progreso en tiempo real cada 0.05 segundos (más fluido)
        task.spawn(function()
                while R.currentSound and R.musicPlayerPanel.Visible do
                        if R.currentSound.IsPlaying then
                                local current = R.currentSound.TimePosition
                                local total = R.currentSound.TimeLength
                                
                                if total > 0 then
                                        local progress = current / total
                                        R.musicProgressBar:TweenSize(
                                                UDim2.new(progress, 0, 1, 0),
                                                Enum.EasingDirection.Out,
                                                Enum.EasingStyle.Linear,
                                                0.05,
                                                true
                                        )
                                        
                                        local minutes = math.floor(current / 60)
                                        local seconds = math.floor(current % 60)
                                        R.currentTimeLabel.Text = string.format("%d:%02d", minutes, seconds)
                                end
                        end
                        task.wait(0.05)
                end
        end)

        -- Mostrar reproductor
        R.musicPlayerPanel.Visible = true
end

-- Función para cargar música
R.loadMusic = function(query)
        for _, child in ipairs(R.resultsScrollFrame:GetChildren()) do
                if child:IsA("Frame") or child:IsA("TextLabel") then
                        child:Destroy()
                end
        end

        local success, musicList = pcall(function()
                return R.getMusicEvent:InvokeServer()
        end)

        if not success or not musicList then
                warn("Error al cargar música")
                return
        end

        -- Filtrar por query si existe
        local filteredMusic = {}
        if query and query ~= "" then
                local queryLower = string.lower(query)
                for _, music in ipairs(musicList) do
                        local nameLower = string.lower(music.name)
                        local categoryLower = string.lower(music.category)
                        if string.find(nameLower, queryLower) or string.find(categoryLower, queryLower) then
                                table.insert(filteredMusic, music)
                        end
                end
        else
                filteredMusic = musicList
        end

        if #filteredMusic == 0 then
                local noResults = Instance.new("TextLabel")
                noResults.Size = UDim2.new(1, 0, 0, 100)
                noResults.BackgroundTransparency = 1
                noResults.Text = query == "" and "No hay música disponible" or "No se encontró música para " .. query
                noResults.Font = Enum.Font.Gotham
                noResults.TextSize = 18
                noResults.TextColor3 = Color3.fromRGB(150, 150, 150)
                noResults.Parent = R.resultsScrollFrame
        else
                for i, music in ipairs(filteredMusic) do
                        local musicCard = Instance.new("Frame")
                        musicCard.Size = UDim2.new(1, 0, 0, 120)
                        musicCard.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                        musicCard.BorderSizePixel = 0
                        musicCard.LayoutOrder = i
                        musicCard.Parent = R.resultsScrollFrame

                        local musicCardCorner = Instance.new("UICorner")
                        musicCardCorner.CornerRadius = UDim.new(0, 10)
                        musicCardCorner.Parent = musicCard

                        local musicCardLayout = Instance.new("UIListLayout")
                        musicCardLayout.SortOrder = Enum.SortOrder.LayoutOrder
                        musicCardLayout.Padding = UDim.new(0, 6)
                        musicCardLayout.Parent = musicCard

                        local musicCardPadding = Instance.new("UIPadding")
                        musicCardPadding.PaddingLeft = UDim.new(0, 15)
                        musicCardPadding.PaddingRight = UDim.new(0, 15)
                        musicCardPadding.PaddingTop = UDim.new(0, 15)
                        musicCardPadding.PaddingBottom = UDim.new(0, 15)
                        musicCardPadding.Parent = musicCard

                        -- Contenedor para título y precio
                        local titleContainer = Instance.new("Frame")
                        titleContainer.Size = UDim2.new(1, 0, 0, 24)
                        titleContainer.BackgroundTransparency = 1
                        titleContainer.LayoutOrder = 1
                        titleContainer.Parent = musicCard

                        local titleLayout = Instance.new("UIListLayout")
                        titleLayout.FillDirection = Enum.FillDirection.Horizontal
                        titleLayout.VerticalAlignment = Enum.VerticalAlignment.Center
                        titleLayout.Padding = UDim.new(0, 8)
                        titleLayout.Parent = titleContainer

                        local musicTitle = Instance.new("TextButton")
                        musicTitle.Size = UDim2.new(0, 0, 0, 24)
                        musicTitle.AutomaticSize = Enum.AutomaticSize.X
                        musicTitle.BackgroundTransparency = 1
                        musicTitle.Text = "🎵 " .. music.name
                        musicTitle.Font = Enum.Font.GothamBold
                        musicTitle.TextSize = 18
                        musicTitle.TextColor3 = Color3.fromRGB(255, 87, 34)
                        musicTitle.TextXAlignment = Enum.TextXAlignment.Left
                        musicTitle.Parent = titleContainer

                        -- Etiqueta de precio verde si es de pago
                        if music.price and music.price > 0 then
                                local priceTag = Instance.new("Frame")
                                priceTag.Size = UDim2.new(0, 0, 0, 22)
                                priceTag.AutomaticSize = Enum.AutomaticSize.X
                                priceTag.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
                                priceTag.Parent = titleContainer

                                local priceCorner = Instance.new("UICorner")
                                priceCorner.CornerRadius = UDim.new(0, 6)
                                priceCorner.Parent = priceTag

                                local priceLabel = Instance.new("TextLabel")
                                priceLabel.Size = UDim2.new(1, 0, 1, 0)
                                priceLabel.BackgroundTransparency = 1
                                priceLabel.Text = " " .. music.price .. " R$ "
                                priceLabel.Font = Enum.Font.GothamBold
                                priceLabel.TextSize = 13
                                priceLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                                priceLabel.Parent = priceTag
                        end
                        
                        musicTitle.MouseButton1Click:Connect(function()
                                -- Verificar si necesita pago
                                if music.price and music.price > 0 then
                                        -- Verificar si ya compró
                                        local success, result = pcall(function()
                                                return R.purchaseMusicEvent:InvokeServer(music.id)
                                        end)
                                        
                                        if success and result then
                                                R.openMusicPlayer(music)
                                        end
                                else
                                        R.openMusicPlayer(music)
                                end
                        end)

                        local musicCategory = Instance.new("TextLabel")
                        musicCategory.Size = UDim2.new(1, 0, 0, 20)
                        musicCategory.BackgroundTransparency = 1
                        musicCategory.Text = "Categoría: " .. music.category
                        musicCategory.Font = Enum.Font.Gotham
                        musicCategory.TextSize = 14
                        musicCategory.TextColor3 = Color3.fromRGB(100, 100, 100)
                        musicCategory.TextXAlignment = Enum.TextXAlignment.Left
                        musicCategory.LayoutOrder = 2
                        musicCategory.Parent = musicCard

                        local musicAuthor = Instance.new("TextLabel")
                        musicAuthor.Size = UDim2.new(1, 0, 0, 18)
                        musicAuthor.BackgroundTransparency = 1
                        musicAuthor.Text = "Por " .. music.author .. " • " .. music.dateCreated
                        musicAuthor.Font = Enum.Font.Gotham
                        musicAuthor.TextSize = 13
                        musicAuthor.TextColor3 = Color3.fromRGB(120, 120, 120)
                        musicAuthor.TextXAlignment = Enum.TextXAlignment.Left
                        musicAuthor.LayoutOrder = 3
                        musicAuthor.Parent = musicCard

                        local divider = Instance.new("Frame")
                        divider.Size = UDim2.new(1, 0, 0, 1)
                        divider.BackgroundColor3 = Color3.fromRGB(230, 230, 230)
                        divider.BorderSizePixel = 0
                        divider.LayoutOrder = 4
                        divider.Parent = musicCard
                end
        end

        task.wait(0.1)
        R.resultsScrollFrame.CanvasSize = UDim2.new(0, 0, 0, R.resultsLayout.AbsoluteContentSize.Y + 60)
end

-- Función para crear sección de creadores destacados
R.createFeaturedCreators = function(parent, layoutOrder)
        -- CAMBIO: Usar evento que funciona para todos los usuarios
        local success, users = pcall(function()
                return R.getVerifiedUsersEvent:InvokeServer()
        end)

        if not success or not users or #users == 0 then
                return
        end

        -- Ya vienen solo verificados del servidor
        local verifiedUsers = users

        if #verifiedUsers == 0 then
                return
        end

        local creatorsSection = Instance.new("Frame")
        creatorsSection.Size = UDim2.new(1, 0, 0, 260)
        creatorsSection.BackgroundTransparency = 1
        creatorsSection.LayoutOrder = layoutOrder
        creatorsSection.Parent = parent

        local creatorsLayout = Instance.new("UIListLayout")
        creatorsLayout.SortOrder = Enum.SortOrder.LayoutOrder
        creatorsLayout.Padding = UDim.new(0, 10)
        creatorsLayout.Parent = creatorsSection

        local creatorsTitle = Instance.new("TextLabel")
        creatorsTitle.Size = UDim2.new(1, 0, 0, 30)
        creatorsTitle.BackgroundTransparency = 1
        creatorsTitle.Text = "✨ Creadores Destacados"
        creatorsTitle.Font = Enum.Font.GothamBold
        creatorsTitle.TextSize = 22
        creatorsTitle.TextColor3 = Color3.fromRGB(0, 0, 0)
        creatorsTitle.TextXAlignment = Enum.TextXAlignment.Left
        creatorsTitle.LayoutOrder = 1
        creatorsTitle.Parent = creatorsSection

        local creatorsScroll = Instance.new("ScrollingFrame")
        creatorsScroll.Size = UDim2.new(1, 0, 0, 220)
        creatorsScroll.BackgroundTransparency = 1
        creatorsScroll.BorderSizePixel = 0
        creatorsScroll.ScrollBarThickness = 4
        creatorsScroll.ScrollBarImageColor3 = Color3.fromRGB(200, 200, 200)
        creatorsScroll.ScrollingDirection = Enum.ScrollingDirection.X
        creatorsScroll.CanvasSize = UDim2.new(0, #verifiedUsers * 170, 0, 0)
        creatorsScroll.LayoutOrder = 2
        creatorsScroll.Parent = creatorsSection

        local creatorsScrollLayout = Instance.new("UIListLayout")
        creatorsScrollLayout.FillDirection = Enum.FillDirection.Horizontal
        creatorsScrollLayout.Padding = UDim.new(0, 15)
        creatorsScrollLayout.Parent = creatorsScroll

        for i, creator in ipairs(verifiedUsers) do
                local creatorCard = Instance.new("Frame")
                creatorCard.Size = UDim2.new(0, 150, 0, 210)
                creatorCard.BackgroundColor3 = Color3.fromRGB(250, 250, 250)
                creatorCard.BorderSizePixel = 0
                creatorCard.LayoutOrder = i
                creatorCard.Parent = creatorsScroll

                local creatorCardCorner = Instance.new("UICorner")
                creatorCardCorner.CornerRadius = UDim.new(0, 15)
                creatorCardCorner.Parent = creatorCard

                local creatorCardLayout = Instance.new("UIListLayout")
                creatorCardLayout.SortOrder = Enum.SortOrder.LayoutOrder
                creatorCardLayout.Padding = UDim.new(0, 10)
                creatorCardLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
                creatorCardLayout.Parent = creatorCard

                local creatorCardPadding = Instance.new("UIPadding")
                creatorCardPadding.PaddingTop = UDim.new(0, 20)
                creatorCardPadding.PaddingBottom = UDim.new(0, 15)
                creatorCardPadding.Parent = creatorCard

                -- Botón de foto circular clickeable
                local creatorImageButton = Instance.new("ImageButton")
                creatorImageButton.Size = UDim2.new(0, 100, 0, 100)
                creatorImageButton.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
                creatorImageButton.Image = creator.thumbnail
                creatorImageButton.LayoutOrder = 1
                creatorImageButton.Parent = creatorCard

                local creatorImageCorner = Instance.new("UICorner")
                creatorImageCorner.CornerRadius = UDim.new(1, 0)
                creatorImageCorner.Parent = creatorImageButton

                -- Click en la foto abre el perfil
                creatorImageButton.MouseButton1Click:Connect(function()
                        R.showUserProfile(creator.userId)
                end)

                -- Nombre clickeable
                local creatorNameButton = Instance.new("TextButton")
                creatorNameButton.Size = UDim2.new(1, -10, 0, 22)
                creatorNameButton.BackgroundTransparency = 1
                creatorNameButton.Text = creator.username
                creatorNameButton.Font = Enum.Font.GothamBold
                creatorNameButton.TextSize = 15
                creatorNameButton.TextColor3 = Color3.fromRGB(0, 0, 0)
                creatorNameButton.TextTruncate = Enum.TextTruncate.AtEnd
                creatorNameButton.LayoutOrder = 2
                creatorNameButton.Parent = creatorCard

                creatorNameButton.MouseButton1Click:Connect(function()
                        R.showUserProfile(creator.userId)
                end)

                -- Botón seguir circular con +
                local followBtn = Instance.new("TextButton")
                followBtn.Name = "FollowButton"
                followBtn.Size = UDim2.new(0, 45, 0, 45)
                followBtn.BackgroundColor3 = Color3.fromRGB(66, 133, 244)
                followBtn.Text = "+"
                followBtn.Font = Enum.Font.GothamBold
                followBtn.TextSize = 26
                followBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                followBtn.BorderSizePixel = 0
                followBtn.LayoutOrder = 3
                followBtn.Parent = creatorCard

                local followBtnCorner = Instance.new("UICorner")
                followBtnCorner.CornerRadius = UDim.new(1, 0)
                followBtnCorner.Parent = followBtn

                -- Verificar si ya sigue
                task.spawn(function()
                        local success, profileData = pcall(function()
                                return R.getUserProfileEvent:InvokeServer(creator.userId)
                        end)

                        if success and profileData and profileData.isFollowing then
                                followBtn.Text = "✓"
                                followBtn.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
                        end
                end)

                -- Evento de clic con animación
                followBtn.MouseButton1Click:Connect(function()
                        local isFollowing = (followBtn.Text == "✓")
                        
                        -- Animación de escala
                        local originalSize = followBtn.Size
                        followBtn:TweenSize(
                                UDim2.new(0, 40, 0, 40),
                                Enum.EasingDirection.Out,
                                Enum.EasingStyle.Quad,
                                0.1,
                                true,
                                function()
                                        followBtn:TweenSize(
                                                originalSize,
                                                Enum.EasingDirection.Out,
                                                Enum.EasingStyle.Bounce,
                                                0.2,
                                                true
                                        )
                                end
                        )

                        if isFollowing then
                                -- Dejar de seguir
                                local success = pcall(function()
                                        return R.unfollowUserEvent:InvokeServer(creator.userId)
                                end)
                                if success then
                                        followBtn.Text = "+"
                                        followBtn.BackgroundColor3 = Color3.fromRGB(66, 133, 244)
                                end
                        else
                                -- Seguir
                                local success = pcall(function()
                                        return R.followUserEvent:InvokeServer(creator.userId)
                                end)
                                if success then
                                        followBtn.Text = "✓"
                                        followBtn.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
                                end
                        end
                end)
        end
end

-- (loadHomeSections ya está definida al inicio del archivo)

R.runSearch = function(textBox)
        local query = textBox.Text
        R.setInterfaceView("results")
        R.searchBoxHeader.Text = query
        
        -- Cargar según pestaña activa
        if R.activeSearchTab == "music" then
                R.loadMusic(query)
        else
                R.loadArticles(query)
        end
end

R.loadAllArticles = function()
        if not R.isAdmin or not R.allArticlesContainer then
                return
        end

        -- Limpiar artículos anteriores
        for _, child in ipairs(R.allArticlesContainer:GetChildren()) do
                if child:IsA("Frame") then
                        child:Destroy()
                end
        end

        local success, allArticles = pcall(function()
                return R.getAllArticlesEvent:InvokeServer()
        end)

        if not success or not allArticles then
                warn("Error al cargar todos los artículos")
                return
        end

        if #allArticles == 0 then
                local noArticles = Instance.new("TextLabel")
                noArticles.Size = UDim2.new(1, 0, 0, 50)
                noArticles.BackgroundTransparency = 1
                noArticles.Text = "No hay artículos en el sistema"
                noArticles.Font = Enum.Font.Gotham
                noArticles.TextSize = 16
                noArticles.TextColor3 = Color3.fromRGB(150, 150, 150)
                noArticles.ZIndex = 12
                noArticles.Parent = R.allArticlesContainer
        else
                -- Ordenar por estado: pending > active > inactive
                local sortedArticles = {}
                for _, article in ipairs(allArticles) do
                        table.insert(sortedArticles, article)
                end
                table.sort(sortedArticles, function(a, b)
                        local order = {pending = 1, active = 2, inactive = 3}
                        return (order[a.status] or 4) < (order[b.status] or 4)
                end)

                for i, article in ipairs(sortedArticles) do
                        local articleCard = Instance.new("Frame")
                        articleCard.Size = UDim2.new(1, 0, 0, 180)
                        articleCard.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                        articleCard.BorderSizePixel = 0
                        articleCard.LayoutOrder = i
                        articleCard.ZIndex = 12
                        articleCard.Parent = R.allArticlesContainer

                        local articleCardCorner = Instance.new("UICorner")
                        articleCardCorner.CornerRadius = UDim.new(0, 8)
                        articleCardCorner.Parent = articleCard

                        local articleCardStroke = Instance.new("UIStroke")
                        articleCardStroke.Color = Color3.fromRGB(220, 220, 220)
                        articleCardStroke.Thickness = 1
                        articleCardStroke.Parent = articleCard

                        local articleCardLayout = Instance.new("UIListLayout")
                        articleCardLayout.SortOrder = Enum.SortOrder.LayoutOrder
                        articleCardLayout.Padding = UDim.new(0, 8)
                        articleCardLayout.Parent = articleCard

                        local articleCardPadding = Instance.new("UIPadding")
                        articleCardPadding.PaddingLeft = UDim.new(0, 15)
                        articleCardPadding.PaddingRight = UDim.new(0, 15)
                        articleCardPadding.PaddingTop = UDim.new(0, 12)
                        articleCardPadding.PaddingBottom = UDim.new(0, 12)
                        articleCardPadding.Parent = articleCard

                        -- Estado del artículo
                        local statusLabel = Instance.new("TextLabel")
                        statusLabel.Size = UDim2.new(1, 0, 0, 20)
                        statusLabel.BackgroundTransparency = 1
                        local statusText = {pending = "⏳ PENDIENTE", active = "✅ ACTIVO", inactive = "❌ INACTIVO"}
                        local statusColor = {pending = Color3.fromRGB(255, 152, 0), active = Color3.fromRGB(76, 175, 80), inactive = Color3.fromRGB(244, 67, 54)}
                        statusLabel.Text = statusText[article.status] or "DESCONOCIDO"
                        statusLabel.Font = Enum.Font.GothamBold
                        statusLabel.TextSize = 14
                        statusLabel.TextColor3 = statusColor[article.status] or Color3.fromRGB(100, 100, 100)
                        statusLabel.TextXAlignment = Enum.TextXAlignment.Left
                        statusLabel.LayoutOrder = 1
                        statusLabel.ZIndex = 13
                        statusLabel.Parent = articleCard

                        local articleTitle = Instance.new("TextLabel")
                        articleTitle.Size = UDim2.new(1, 0, 0, 25)
                        articleTitle.BackgroundTransparency = 1
                        articleTitle.Text = article.title
                        articleTitle.Font = Enum.Font.GothamBold
                        articleTitle.TextSize = 18
                        articleTitle.TextColor3 = Color3.fromRGB(0, 0, 0)
                        articleTitle.TextXAlignment = Enum.TextXAlignment.Left
                        articleTitle.TextWrapped = true
                        articleTitle.LayoutOrder = 2
                        articleTitle.ZIndex = 13
                        articleTitle.Parent = articleCard

                        local articleDesc = Instance.new("TextLabel")
                        articleDesc.Size = UDim2.new(1, 0, 0, 40)
                        articleDesc.BackgroundTransparency = 1
                        articleDesc.Text = string.sub(article.description, 1, 100) .. (string.len(article.description) > 100 and "..." or "")
                        articleDesc.Font = Enum.Font.Gotham
                        articleDesc.TextSize = 14
                        articleDesc.TextColor3 = Color3.fromRGB(100, 100, 100)
                        articleDesc.TextXAlignment = Enum.TextXAlignment.Left
                        articleDesc.TextYAlignment = Enum.TextYAlignment.Top
                        articleDesc.TextWrapped = true
                        articleDesc.LayoutOrder = 3
                        articleDesc.ZIndex = 13
                        articleDesc.Parent = articleCard

                        local articleAuthor = Instance.new("TextLabel")
                        articleAuthor.Size = UDim2.new(1, 0, 0, 18)
                        articleAuthor.BackgroundTransparency = 1
                        articleAuthor.Text = "Por " .. article.author .. " • " .. article.dateCreated
                        articleAuthor.Font = Enum.Font.Gotham
                        articleAuthor.TextSize = 13
                        articleAuthor.TextColor3 = Color3.fromRGB(120, 120, 120)
                        articleAuthor.TextXAlignment = Enum.TextXAlignment.Left
                        articleAuthor.LayoutOrder = 4
                        articleAuthor.ZIndex = 13
                        articleAuthor.Parent = articleCard

                        local buttonsContainer = Instance.new("Frame")
                        buttonsContainer.Size = UDim2.new(1, 0, 0, 40)
                        buttonsContainer.BackgroundTransparency = 1
                        buttonsContainer.LayoutOrder = 5
                        buttonsContainer.ZIndex = 13
                        buttonsContainer.Parent = articleCard

                        local buttonsLayout = Instance.new("UIListLayout")
                        buttonsLayout.FillDirection = Enum.FillDirection.Horizontal
                        buttonsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
                        buttonsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
                        buttonsLayout.Padding = UDim.new(0, 15)
                        buttonsLayout.Parent = buttonsContainer

                        -- Botones según el estado
                        if article.status == "pending" then
                                -- Aprobar
                                local approveButton = Instance.new("TextButton")
                                approveButton.Size = UDim2.new(0, 120, 0, 35)
                                approveButton.BackgroundColor3 = Color3.fromRGB(52, 168, 83)
                                approveButton.Text = "✓ Aprobar"
                                approveButton.Font = Enum.Font.GothamBold
                                approveButton.TextSize = 15
                                approveButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                                approveButton.BorderSizePixel = 0
                                approveButton.ZIndex = 14
                                approveButton.Parent = buttonsContainer

                                local approveCorner = Instance.new("UICorner")
                                approveCorner.CornerRadius = UDim.new(0, 8)
                                approveCorner.Parent = approveButton

                                -- Rechazar
                                local rejectButton = Instance.new("TextButton")
                                rejectButton.Size = UDim2.new(0, 120, 0, 35)
                                rejectButton.BackgroundColor3 = Color3.fromRGB(234, 67, 53)
                                rejectButton.Text = "✗ Rechazar"
                                rejectButton.Font = Enum.Font.GothamBold
                                rejectButton.TextSize = 15
                                rejectButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                                rejectButton.BorderSizePixel = 0
                                rejectButton.ZIndex = 14
                                rejectButton.Parent = buttonsContainer

                                local rejectCorner = Instance.new("UICorner")
                                rejectCorner.CornerRadius = UDim.new(0, 8)
                                rejectCorner.Parent = rejectButton

                                approveButton.MouseButton1Click:Connect(function()
                                        local success = R.toggleArticleStatusEvent:InvokeServer(article.id, "active")
                                        if success then
                                                R.loadAllArticles()
                                        end
                                end)

                                rejectButton.MouseButton1Click:Connect(function()
                                        local success = R.toggleArticleStatusEvent:InvokeServer(article.id, "inactive")
                                        if success then
                                                R.loadAllArticles()
                                        end
                                end)

                        elseif article.status == "active" then
                                -- Desactivar
                                local deactivateButton = Instance.new("TextButton")
                                deactivateButton.Size = UDim2.new(0, 140, 0, 35)
                                deactivateButton.BackgroundColor3 = Color3.fromRGB(234, 67, 53)
                                deactivateButton.Text = "Desactivar"
                                deactivateButton.Font = Enum.Font.GothamBold
                                deactivateButton.TextSize = 15
                                deactivateButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                                deactivateButton.BorderSizePixel = 0
                                deactivateButton.ZIndex = 14
                                deactivateButton.Parent = buttonsContainer

                                local deactivateCorner = Instance.new("UICorner")
                                deactivateCorner.CornerRadius = UDim.new(0, 8)
                                deactivateCorner.Parent = deactivateButton

                                deactivateButton.MouseButton1Click:Connect(function()
                                        local success = R.toggleArticleStatusEvent:InvokeServer(article.id, "inactive")
                                        if success then
                                                R.loadAllArticles()
                                        end
                                end)

                        else -- inactive
                                -- Reactivar
                                local reactivateButton = Instance.new("TextButton")
                                reactivateButton.Size = UDim2.new(0, 140, 0, 35)
                                reactivateButton.BackgroundColor3 = Color3.fromRGB(52, 168, 83)
                                reactivateButton.Text = "Reactivar"
                                reactivateButton.Font = Enum.Font.GothamBold
                                reactivateButton.TextSize = 15
                                reactivateButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                                reactivateButton.BorderSizePixel = 0
                                reactivateButton.ZIndex = 14
                                reactivateButton.Parent = buttonsContainer

                                local reactivateCorner = Instance.new("UICorner")
                                reactivateCorner.CornerRadius = UDim.new(0, 8)
                                reactivateCorner.Parent = reactivateButton

                                reactivateButton.MouseButton1Click:Connect(function()
                                        local success = R.toggleArticleStatusEvent:InvokeServer(article.id, "active")
                                        if success then
                                                R.loadAllArticles()
                                        end
                                end)
                        end
                end
        end

        task.wait(0.1)
        R.allArticlesContainer.CanvasSize = UDim2.new(0, 0, 0, R.allArticlesContainer:FindFirstChildOfClass("UIListLayout").AbsoluteContentSize.Y + 30)

        task.wait(0.1)
        R.adminPanel.CanvasSize = UDim2.new(0, 0, 0, R.adminPanel:FindFirstChildOfClass("UIListLayout").AbsoluteContentSize.Y + 60)
end

-- Función para buscar y mostrar usuarios (panel admin)
-- Función para cargar y mostrar todas las músicas (panel admin)
R.loadAllMusic = function()
        if not R.isAdmin or not R.allMusicContainer then
                return
        end

        -- Limpiar músicas anteriores
        for _, child in ipairs(R.allMusicContainer:GetChildren()) do
                if child:IsA("Frame") then
                        child:Destroy()
                end
        end

        local success, allMusic = pcall(function()
                return R.getPendingMusicEvent:InvokeServer()
        end)

        if not success or not allMusic then
                warn("Error al cargar músicas")
                return
        end

        if #allMusic == 0 then
                local noMusic = Instance.new("TextLabel")
                noMusic.Size = UDim2.new(1, 0, 0, 50)
                noMusic.BackgroundTransparency = 1
                noMusic.Text = "No hay músicas pendientes"
                noMusic.Font = Enum.Font.Gotham
                noMusic.TextSize = 16
                noMusic.TextColor3 = Color3.fromRGB(150, 150, 150)
                noMusic.ZIndex = 12
                noMusic.Parent = R.allMusicContainer
        else
                for i, music in ipairs(allMusic) do
                        local musicCard = Instance.new("Frame")
                        musicCard.Size = UDim2.new(1, 0, 0, 140)
                        musicCard.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                        musicCard.BorderSizePixel = 0
                        musicCard.LayoutOrder = i
                        musicCard.ZIndex = 12
                        musicCard.Parent = R.allMusicContainer

                        local musicCardCorner = Instance.new("UICorner")
                        musicCardCorner.CornerRadius = UDim.new(0, 8)
                        musicCardCorner.Parent = musicCard

                        local musicCardStroke = Instance.new("UIStroke")
                        musicCardStroke.Color = Color3.fromRGB(220, 220, 220)
                        musicCardStroke.Thickness = 1
                        musicCardStroke.Parent = musicCard

                        local musicCardLayout = Instance.new("UIListLayout")
                        musicCardLayout.SortOrder = Enum.SortOrder.LayoutOrder
                        musicCardLayout.Padding = UDim.new(0, 8)
                        musicCardLayout.Parent = musicCard

                        local musicCardPadding = Instance.new("UIPadding")
                        musicCardPadding.PaddingLeft = UDim.new(0, 15)
                        musicCardPadding.PaddingRight = UDim.new(0, 15)
                        musicCardPadding.PaddingTop = UDim.new(0, 15)
                        musicCardPadding.PaddingBottom = UDim.new(0, 15)
                        musicCardPadding.Parent = musicCard

                        local musicTitle = Instance.new("TextLabel")
                        musicTitle.Size = UDim2.new(1, 0, 0, 24)
                        musicTitle.BackgroundTransparency = 1
                        musicTitle.Text = "🎵 " .. music.name
                        musicTitle.Font = Enum.Font.GothamBold
                        musicTitle.TextSize = 18
                        musicTitle.TextColor3 = Color3.fromRGB(0, 0, 0)
                        musicTitle.TextXAlignment = Enum.TextXAlignment.Left
                        musicTitle.TextWrapped = true
                        musicTitle.LayoutOrder = 1
                        musicTitle.ZIndex = 13
                        musicTitle.Parent = musicCard

                        local musicCategory = Instance.new("TextLabel")
                        musicCategory.Size = UDim2.new(1, 0, 0, 18)
                        musicCategory.BackgroundTransparency = 1
                        musicCategory.Text = "Categoría: " .. music.category
                        musicCategory.Font = Enum.Font.Gotham
                        musicCategory.TextSize = 14
                        musicCategory.TextColor3 = Color3.fromRGB(120, 120, 120)
                        musicCategory.TextXAlignment = Enum.TextXAlignment.Left
                        musicCategory.LayoutOrder = 2
                        musicCategory.ZIndex = 13
                        musicCategory.Parent = musicCard

                        local musicId = Instance.new("TextLabel")
                        musicId.Size = UDim2.new(1, 0, 0, 18)
                        musicId.BackgroundTransparency = 1
                        musicId.Text = "ID Audio: " .. music.audioId
                        musicId.Font = Enum.Font.Gotham
                        musicId.TextSize = 13
                        musicId.TextColor3 = Color3.fromRGB(120, 120, 120)
                        musicId.TextXAlignment = Enum.TextXAlignment.Left
                        musicId.LayoutOrder = 3
                        musicId.ZIndex = 13
                        musicId.Parent = musicCard

                        local musicAuthor = Instance.new("TextLabel")
                        musicAuthor.Size = UDim2.new(1, 0, 0, 18)
                        musicAuthor.BackgroundTransparency = 1
                        musicAuthor.Text = "Por " .. music.author .. " • " .. music.dateCreated
                        musicAuthor.Font = Enum.Font.Gotham
                        musicAuthor.TextSize = 13
                        musicAuthor.TextColor3 = Color3.fromRGB(120, 120, 120)
                        musicAuthor.TextXAlignment = Enum.TextXAlignment.Left
                        musicAuthor.LayoutOrder = 4
                        musicAuthor.ZIndex = 13
                        musicAuthor.Parent = musicCard

                        local buttonsContainer = Instance.new("Frame")
                        buttonsContainer.Size = UDim2.new(1, 0, 0, 35)
                        buttonsContainer.BackgroundTransparency = 1
                        buttonsContainer.LayoutOrder = 5
                        buttonsContainer.ZIndex = 13
                        buttonsContainer.Parent = musicCard

                        local buttonsLayout = Instance.new("UIListLayout")
                        buttonsLayout.FillDirection = Enum.FillDirection.Horizontal
                        buttonsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
                        buttonsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
                        buttonsLayout.Padding = UDim.new(0, 15)
                        buttonsLayout.Parent = buttonsContainer

                        -- Botón aprobar
                        local approveButton = Instance.new("TextButton")
                        approveButton.Size = UDim2.new(0, 120, 0, 35)
                        approveButton.BackgroundColor3 = Color3.fromRGB(52, 168, 83)
                        approveButton.Text = "✓ Aprobar"
                        approveButton.Font = Enum.Font.GothamBold
                        approveButton.TextSize = 15
                        approveButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                        approveButton.BorderSizePixel = 0
                        approveButton.ZIndex = 14
                        approveButton.Parent = buttonsContainer

                        local approveCorner = Instance.new("UICorner")
                        approveCorner.CornerRadius = UDim.new(0, 8)
                        approveCorner.Parent = approveButton

                        -- Botón rechazar
                        local rejectButton = Instance.new("TextButton")
                        rejectButton.Size = UDim2.new(0, 120, 0, 35)
                        rejectButton.BackgroundColor3 = Color3.fromRGB(234, 67, 53)
                        rejectButton.Text = "✗ Rechazar"
                        rejectButton.Font = Enum.Font.GothamBold
                        rejectButton.TextSize = 15
                        rejectButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                        rejectButton.BorderSizePixel = 0
                        rejectButton.ZIndex = 14
                        rejectButton.Parent = buttonsContainer

                        local rejectCorner = Instance.new("UICorner")
                        rejectCorner.CornerRadius = UDim.new(0, 8)
                        rejectCorner.Parent = rejectButton

                        approveButton.MouseButton1Click:Connect(function()
                                local success = R.toggleMusicStatusEvent:InvokeServer(music.id, "active")
                                if success then
                                        R.loadAllMusic()
                                end
                        end)

                        rejectButton.MouseButton1Click:Connect(function()
                                local success = R.toggleMusicStatusEvent:InvokeServer(music.id, "inactive")
                                if success then
                                        R.loadAllMusic()
                                end
                        end)
                end
        end

        task.wait(0.1)
        R.allMusicContainer.CanvasSize = UDim2.new(0, 0, 0, R.allMusicContainer:FindFirstChildOfClass("UIListLayout").AbsoluteContentSize.Y + 30)
end

-- Función para buscar y mostrar usuarios (panel admin)
R.searchAndDisplayUsers = function(query)
        if not R.isAdmin or not R.adminScrollContainer then
                return
        end

        -- Limpiar resultados anteriores
        for _, child in ipairs(R.adminScrollContainer:GetChildren()) do
                if child:IsA("Frame") then
                        child:Destroy()
                end
        end

        local success, users = pcall(function()
                return R.searchUsersEvent:InvokeServer(query)
        end)

        if not success or not users then
                warn("Error al buscar usuarios")
                return
        end

        if #users == 0 then
                local noUsers = Instance.new("TextLabel")
                noUsers.Size = UDim2.new(1, 0, 0, 50)
                noUsers.BackgroundTransparency = 1
                noUsers.Text = query == "" and "No hay usuarios registrados" or "No se encontraron usuarios"
                noUsers.Font = Enum.Font.Gotham
                noUsers.TextSize = 16
                noUsers.TextColor3 = Color3.fromRGB(150, 150, 150)
                noUsers.ZIndex = 12
                noUsers.Parent = R.adminScrollContainer
        else
                for i, user in ipairs(users) do
                        local userCard = Instance.new("Frame")
                        userCard.Size = UDim2.new(1, 0, 0, 80)
                        userCard.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                        userCard.BorderSizePixel = 0
                        userCard.LayoutOrder = i
                        userCard.ZIndex = 12
                        userCard.Parent = R.adminScrollContainer

                        local userCardCorner = Instance.new("UICorner")
                        userCardCorner.CornerRadius = UDim.new(0, 8)
                        userCardCorner.Parent = userCard

                        local userCardStroke = Instance.new("UIStroke")
                        userCardStroke.Color = Color3.fromRGB(220, 220, 220)
                        userCardStroke.Thickness = 1
                        userCardStroke.Parent = userCard

                        -- Foto del usuario
                        local userImage = Instance.new("ImageLabel")
                        userImage.Size = UDim2.new(0, 50, 0, 50)
                        userImage.Position = UDim2.new(0, 15, 0.5, -25)
                        userImage.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
                        userImage.Image = user.thumbnail
                        userImage.ZIndex = 13
                        userImage.Parent = userCard

                        local userImageCorner = Instance.new("UICorner")
                        userImageCorner.CornerRadius = UDim.new(1, 0)
                        userImageCorner.Parent = userImage

                        -- Información del usuario
                        local userInfoFrame = Instance.new("Frame")
                        userInfoFrame.Size = UDim2.new(1, -180, 1, 0)
                        userInfoFrame.Position = UDim2.new(0, 75, 0, 0)
                        userInfoFrame.BackgroundTransparency = 1
                        userInfoFrame.ZIndex = 13
                        userInfoFrame.Parent = userCard

                        local userInfoLayout = Instance.new("UIListLayout")
                        userInfoLayout.SortOrder = Enum.SortOrder.LayoutOrder
                        userInfoLayout.Padding = UDim.new(0, 5)
                        userInfoLayout.VerticalAlignment = Enum.VerticalAlignment.Center
                        userInfoLayout.Parent = userInfoFrame

                        -- Nombre con insignia
                        local usernameContainer = Instance.new("Frame")
                        usernameContainer.Name = "UsernameContainer"
                        usernameContainer.Size = UDim2.new(1, 0, 0, 22)
                        usernameContainer.BackgroundTransparency = 1
                        usernameContainer.LayoutOrder = 1
                        usernameContainer.ZIndex = 13
                        usernameContainer.Parent = userInfoFrame

                        local usernameLayout = Instance.new("UIListLayout")
                        usernameLayout.FillDirection = Enum.FillDirection.Horizontal
                        usernameLayout.VerticalAlignment = Enum.VerticalAlignment.Center
                        usernameLayout.Padding = UDim.new(0, 5)
                        usernameLayout.Parent = usernameContainer

                        local usernameLabel = Instance.new("TextLabel")
                        usernameLabel.Size = UDim2.new(0, 0, 0, 22)
                        usernameLabel.AutomaticSize = Enum.AutomaticSize.X
                        usernameLabel.BackgroundTransparency = 1
                        usernameLabel.Text = user.username
                        usernameLabel.Font = Enum.Font.GothamBold
                        usernameLabel.TextSize = 16
                        usernameLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
                        usernameLabel.TextXAlignment = Enum.TextXAlignment.Left
                        usernameLabel.ZIndex = 14
                        usernameLabel.Parent = usernameContainer

                        if user.verified then
                                local verifiedBadge = R.createVerifiedBadge()
                                verifiedBadge.Size = UDim2.new(0, 18, 0, 18)
                                verifiedBadge.ZIndex = 14
                                verifiedBadge.Parent = usernameContainer
                        end

                        -- Estadísticas
                        local userStats = Instance.new("TextLabel")
                        userStats.Size = UDim2.new(1, 0, 0, 18)
                        userStats.BackgroundTransparency = 1
                        userStats.Text = string.format("%d artículos • %d seguidores", user.articlesPublished or 0, #(user.followers or {}))
                        userStats.Font = Enum.Font.Gotham
                        userStats.TextSize = 13
                        userStats.TextColor3 = Color3.fromRGB(120, 120, 120)
                        userStats.TextXAlignment = Enum.TextXAlignment.Left
                        userStats.LayoutOrder = 2
                        userStats.ZIndex = 14
                        userStats.Parent = userInfoFrame

                        -- Botón verificar/desverificar
                        local verifyButton = Instance.new("TextButton")
                        verifyButton.Size = UDim2.new(0, 100, 0, 35)
                        verifyButton.Position = UDim2.new(1, -220, 0.5, -17.5)
                        verifyButton.BackgroundColor3 = user.verified and Color3.fromRGB(200, 200, 200) or Color3.fromRGB(29, 161, 242)
                        verifyButton.Text = user.verified and "Desverificar" or "Verificar"
                        verifyButton.Font = Enum.Font.GothamBold
                        verifyButton.TextSize = 14
                        verifyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                        verifyButton.BorderSizePixel = 0
                        verifyButton.ZIndex = 14
                        verifyButton.Parent = userCard

                        local verifyCorner = Instance.new("UICorner")
                        verifyCorner.CornerRadius = UDim.new(0, 8)
                        verifyCorner.Parent = verifyButton

                        verifyButton.MouseButton1Click:Connect(function()
                                local success
                                if user.verified then
                                        success = R.unverifyUserEvent:InvokeServer(user.userId)
                                        if success then
                                                user.verified = false
                                                verifyButton.Text = "Verificar"
                                                verifyButton.BackgroundColor3 = Color3.fromRGB(29, 161, 242)
                                                -- Remover insignia
                                                for _, child in ipairs(usernameContainer:GetChildren()) do
                                                        if child.Name == "VerifiedBadge" then
                                                                child:Destroy()
                                                        end
                                                end
                                        end
                                else
                                        success = R.verifyUserEvent:InvokeServer(user.userId)
                                        if success then
                                                user.verified = true
                                                verifyButton.Text = "Desverificar"
                                                verifyButton.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
                                                -- Agregar insignia
                                                local verifiedBadge = R.createVerifiedBadge()
                                                verifiedBadge.Size = UDim2.new(0, 18, 0, 18)
                                                verifiedBadge.ZIndex = 14
                                                verifiedBadge.Parent = usernameContainer
                                        end
                                end
                        end)

                        -- Botón bloquear/desbloquear
                        local banButton = Instance.new("TextButton")
                        banButton.Size = UDim2.new(0, 100, 0, 35)
                        banButton.Position = UDim2.new(1, -110, 0.5, -17.5)
                        banButton.BackgroundColor3 = Color3.fromRGB(234, 67, 53)
                        banButton.Text = "Bloquear"
                        banButton.Font = Enum.Font.GothamBold
                        banButton.TextSize = 14
                        banButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                        banButton.BorderSizePixel = 0
                        banButton.ZIndex = 14
                        banButton.Parent = userCard

                        local banCorner = Instance.new("UICorner")
                        banCorner.CornerRadius = UDim.new(0, 8)
                        banCorner.Parent = banButton

                        -- Verificar si ya está baneado
                        task.spawn(function()
                                local success, banStatus = pcall(function()
                                        return R.checkBanStatusEvent:InvokeServer(user.userId)
                                end)

                                if success and banStatus and banStatus.isBanned then
                                        banButton.Text = "Desbloquear"
                                        banButton.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
                                end
                        end)

                        banButton.MouseButton1Click:Connect(function()
                                -- Verificar si está baneado primero
                                local success, banStatus = pcall(function()
                                        return R.checkBanStatusEvent:InvokeServer(user.userId)
                                end)

                                local isBanned = success and banStatus and banStatus.isBanned

                                if isBanned then
                                        -- Desbanear
                                        local success, result = pcall(function()
                                                return R.unbanUserEvent:InvokeServer(user.userId)
                                        end)

                                        if success and result then
                                                banButton.Text = "Bloquear"
                                                banButton.BackgroundColor3 = Color3.fromRGB(234, 67, 53)
                                                print("✓ Usuario desbloqueado:", user.username)
                                                task.wait(1)
                                                R.searchAndDisplayUsers(R.adminSearchBox.Text)
                                        end
                                else
                                        -- Banear
                                        local success, result = pcall(function()
                                                return R.banUserEvent:InvokeServer(user.userId, "Infracción de las normas de la comunidad")
                                        end)

                                        if success and result then
                                                banButton.Text = "Desbloquear"
                                                banButton.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
                                                print("✓ Usuario bloqueado:", user.username)
                                                task.wait(1)
                                                R.searchAndDisplayUsers(R.adminSearchBox.Text)
                                        else
                                                warn("Error al bloquear usuario")
                                        end
                                end
                        end)
                end
        end

        task.wait(0.1)
        R.adminScrollContainer.CanvasSize = UDim2.new(0, 0, 0, R.adminScrollContainer:FindFirstChildOfClass("UIListLayout").AbsoluteContentSize.Y + 30)
end

-- Señal de que Functions terminó de cargar
_G.RoogleFunctionsLoaded = true
print("✓ Roogle Functions (2/3) cargado: Lógica lista.")

