
-- Roogle_Events.LocalScript (3 de 3)
-- Este script conecta TODOS los eventos a las funciones y ejecuta la carga inicial.

-- ESPERAR a que Core y Functions terminen de cargar completamente
repeat task.wait(0.1) until _G.RoogleCoreLoaded and _G.RoogleFunctionsLoaded and _G.RoogleClient
print("⏳ Core y Functions detectados, iniciando Events...")
local R = _G.RoogleClient

-- ========== EVENTOS DE BÚSQUEDA ==========
R.searchBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
                R.runSearch(R.searchBox)
        end
end)

R.searchButton.MouseButton1Click:Connect(function()
        R.runSearch(R.searchBox)
end)

R.searchBoxHeader.FocusLost:Connect(function(enterPressed)
        if enterPressed then
                R.runSearch(R.searchBoxHeader)
        end
end)

R.searchButtonHeader.MouseButton1Click:Connect(function()
        R.runSearch(R.searchBoxHeader)
end)

-- ========== EVENTOS DE NAVEGACIÓN ==========
R.homeButton.MouseButton1Click:Connect(function()
        R.setInterfaceView("home")
end)

R.backButton.MouseButton1Click:Connect(function()
        R.setInterfaceView(R.previousView)
end)

R.profileBackButton.MouseButton1Click:Connect(function()
        R.setInterfaceView(R.previousView)
end)

R.settingsButton.MouseButton1Click:Connect(function()
        R.setInterfaceView("settings")
end)

R.settingsCloseButton.MouseButton1Click:Connect(function()
        R.setInterfaceView("home")
end)

R.termsButton.MouseButton1Click:Connect(function()
        R.setInterfaceView("terms")
end)

R.termsCloseButton.MouseButton1Click:Connect(function()
        R.setInterfaceView("settings")
end)

R.creatorButton.MouseButton1Click:Connect(function()
        R.setInterfaceView("creator")
end)

R.creatorCloseButton.MouseButton1Click:Connect(function()
        R.setInterfaceView("home")
end)

-- ========== EVENTOS DE PESTAÑAS DE BÚSQUEDA ==========
R.articlesTab.MouseButton1Click:Connect(function()
        if R.activeSearchTab ~= "articles" then
                R.activeSearchTab = "articles"
                R.articlesTab.BackgroundColor3 = Color3.fromRGB(66, 133, 244)
                R.articlesTab.TextColor3 = Color3.fromRGB(255, 255, 255)
                R.musicTab.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
                R.musicTab.TextColor3 = Color3.fromRGB(100, 100, 100)
                R.loadArticles(R.searchBoxHeader.Text)
        end
end)

R.musicTab.MouseButton1Click:Connect(function()
        if R.activeSearchTab ~= "music" then
                R.activeSearchTab = "music"
                R.musicTab.BackgroundColor3 = Color3.fromRGB(66, 133, 244)
                R.musicTab.TextColor3 = Color3.fromRGB(255, 255, 255)
                R.articlesTab.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
                R.articlesTab.TextColor3 = Color3.fromRGB(100, 100, 100)
                R.loadMusic(R.searchBoxHeader.Text)
        end
end)

-- ========== EVENTOS DEL CREADOR ==========
R.submitButton.MouseButton1Click:Connect(function()
        local title = R.titleInput.Text
        local category = R.categoryInput.Text
        local content = R.contentInput.Text

        if title == "" or category == "" or content == "" then
                warn("⚠ Por favor completa todos los campos")
                return
        end

        R.loadingPanel.Visible = true

        local success, result = pcall(function()
                return R.publishArticleFunction:InvokeServer(title, category, content)
        end)

        R.loadingPanel.Visible = false

        if success and result then
                R.titleInput.Text = ""
                R.categoryInput.Text = ""
                R.contentInput.Text = ""
                R.setInterfaceView("home")
                print("✓ Artículo enviado a revisión")
        else
                warn("✗ Error al enviar artículo")
        end
end)

-- ========== EVENTOS DEL PANEL DE ADMIN ==========
if R.isAdmin then
        R.adminPanelButton.MouseButton1Click:Connect(function()
                R.setInterfaceView("admin")
                R.searchAndDisplayUsers("")
                R.loadAllArticles()
                R.loadAllMusic()
        end)

        R.adminCloseButton.MouseButton1Click:Connect(function()
                R.setInterfaceView("home")
        end)

        R.refreshButton.MouseButton1Click:Connect(function()
                R.loadAllArticles()
        end)

        R.refreshMusicButton.MouseButton1Click:Connect(function()
                R.loadAllMusic()
        end)

        R.adminSearchBox:GetPropertyChangedSignal("Text"):Connect(function()
                R.searchAndDisplayUsers(R.adminSearchBox.Text)
        end)

        R.systemPublishButton.MouseButton1Click:Connect(function()
                local title = R.systemTitleInput.Text
                local content = R.systemContentInput.Text

                if title == "" or content == "" then
                        warn("⚠ Por favor completa todos los campos")
                        return
                end

                R.loadingPanel.Visible = true
                R.loadingLabel.Text = "Publicando anuncio..."

                local success, result = pcall(function()
                        return R.publishArticleFunction:InvokeServer(title, "Sistema", content, true)
                end)

                R.loadingPanel.Visible = false

                if success and result then
                        R.systemTitleInput.Text = ""
                        R.systemContentInput.Text = ""
                        R.loadAllArticles()
                        print("✓ Anuncio del sistema publicado")
                else
                        warn("✗ Error al publicar anuncio")
                end
        end)
end

-- ========== EVENTOS DEL REPRODUCTOR DE MÚSICA ==========
R.closePlayerButton.MouseButton1Click:Connect(function()
        R.musicPlayerPanel.Visible = false
        if R.currentSound then
                R.currentSound:Stop()
                R.currentSound:Destroy()
                R.currentSound = nil
        end
end)

R.playPauseButton.MouseButton1Click:Connect(function()
        if not R.currentSound then return end
        
        if R.currentSound.IsPlaying then
                R.currentSound:Pause()
                R.playPauseButton.Text = "▶"
        else
                R.currentSound:Play()
                R.playPauseButton.Text = "⏸"
        end
end)

-- ========== CARGA INICIAL ==========
task.wait(0.2)
R.setInterfaceView("home")

print("✓ Articulum Events (3/3) cargado: Sistema completamente funcional.")
