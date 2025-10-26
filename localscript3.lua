-- Roogle_Events.LocalScript (3 de 3)
-- Este script conecta todos los eventos y ejecuta la carga inicial.

-- Esperar a que Core y Functions carguen
-- Esperamos por 'setInterfaceView' para saber que Functions.lua terminó
repeat task.wait() until _G.RoogleClient and _G.RoogleClient.setInterfaceView
local R = _G.RoogleClient

-- ========== EVENTOS ==========

R.searchButton.MouseButton1Click:Connect(function()
        R.runSearch(R.searchBox)
end)

R.searchBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
                R.runSearch(R.searchBox)
        end
end)

-- Búsqueda en header
R.searchButtonHeader.MouseButton1Click:Connect(function()
        R.runSearch(R.searchBoxHeader)
end)

R.searchBoxHeader.FocusLost:Connect(function(enterPressed)
        if enterPressed then
                R.runSearch(R.searchBoxHeader)
        end
end)

-- Volver al inicio desde resultados
R.homeButton.MouseButton1Click:Connect(function()
        R.setInterfaceView("home")
        R.searchBox.Text = ""
end)

R.backButton.MouseButton1Click:Connect(function()
        R.setInterfaceView(R.previousView)
end)

R.profileBackButton.MouseButton1Click:Connect(function()
        R.setInterfaceView(R.previousView)
end)

-- Panel de creador
R.creatorButton.MouseButton1Click:Connect(function()
        R.setInterfaceView("creator")
        R.titleInput.Text = ""
        R.contentInput.Text = ""
end)

R.creatorCloseButton.MouseButton1Click:Connect(function()
        R.setInterfaceView("home")
end)

-- Panel de configuración
R.settingsButton.MouseButton1Click:Connect(function()
        R.setInterfaceView("settings")
end)

R.settingsCloseButton.MouseButton1Click:Connect(function()
        R.setInterfaceView("home")
end)

-- Panel de términos
R.termsButton.MouseButton1Click:Connect(function()
        R.setInterfaceView("terms")
end)

R.termsCloseButton.MouseButton1Click:Connect(function()
        R.setInterfaceView("settings")
end)

R.submitButton.MouseButton1Click:Connect(function()
        local title = R.titleInput.Text
        local category = R.categoryInput.Text
        local content = R.contentInput.Text

        if title ~= "" and category ~= "" and content ~= "" then
                R.loadingPanel.Visible = true
                R.loadingLabel.Text = "Enviando a revisión..."
                R.creatorPanel.Visible = false

                local success, result = pcall(function()
                        return R.publishArticleFunction:InvokeServer(title, content, category, false)
                end)

                R.loadingPanel.Visible = false

                if success and result == true then
                        print("✓ Artículo enviado a revisión")
                        R.titleInput.Text = ""
                        R.categoryInput.Text = ""
                        R.contentInput.Text = ""
                        R.setInterfaceView("home")
                else
                        warn("✗ Error al enviar:", result)
                end
        else
                warn("⚠ Por favor completa todos los campos")
        end
end)

-- Panel de administrador (solo para admins)
if R.isAdmin and R.adminPanelButton and R.adminPanel then
        R.adminPanelButton.MouseButton1Click:Connect(function()
                R.setInterfaceView("admin")
                R.loadAllArticles()
                R.searchAndDisplayUsers("")
        end)

        if R.adminCloseButton then
                R.adminCloseButton.MouseButton1Click:Connect(function()
                        R.setInterfaceView("home")
                end)
        end

        -- Conectar botón de publicar sistema
        if R.systemPublishButton then
                R.systemPublishButton.MouseButton1Click:Connect(function()
                        local title = R.systemTitleInput.Text
                        local content = R.systemContentInput.Text

                        if title ~= "" and content ~= "" then
                                R.loadingPanel.Visible = true
                                R.loadingLabel.Text = "Publicando anuncio del sistema..."

                                -- Pasar true como cuarto parámetro para publicar como Sistema
                                local success, result = pcall(function()
                                        return R.publishArticleFunction:InvokeServer(title, content, "Anuncio", true)
                                end)

                                R.loadingPanel.Visible = false

                                if success and result then
                                        R.systemTitleInput.Text = ""
                                        R.systemContentInput.Text = ""
                                        R.loadAllArticles()
                                        R.loadHomeSections() -- Actualizar página de inicio
                                        print("✓ Anuncio del sistema publicado")
                                else
                                        warn("✗ Error al publicar anuncio")
                                end
                        else
                                warn("⚠ Completa título y contenido")
                        end
                end)
        end
        
        -- Botón actualizar
        if R.refreshButton then
                R.refreshButton.MouseButton1Click:Connect(function()
                        R.loadAllArticles()
                        R.searchAndDisplayUsers(R.adminSearchBox.Text)
                end)
        end

        -- Búsqueda de usuarios en tiempo real
        if R.adminSearchBox then
                R.adminSearchBox:GetPropertyChangedSignal("Text"):Connect(function()
                        R.searchAndDisplayUsers(R.adminSearchBox.Text)
                end)
        end

        -- Botón actualizar música
        if R.refreshMusicButton then
                R.refreshMusicButton.MouseButton1Click:Connect(function()
                        R.loadAllMusic()
                end)
        end
end

-- ========== CARGA INICIAL ==========
R.loadArticles("")
R.loadHomeSections()

print("✓ Roogle Events (3/3) cargado: Eventos conectados.")
print("✓ Roogle cargado exitosamente")
print("✓ Interfaz lista para usar")
print("✓ Persistencia de datos activada")
print("✓ Sistema de perfiles implementado")
print("✓ Insignias de verificación con palomita activadas")
print("✓ Sistema de estados (pending/active/inactive)")
if R.isAdmin then
        print("✓ Modo administrador activado")
        print("✓ Panel admin con gestión completa de artículos")
        print("✓ Panel admin con búsqueda de usuarios en tiempo real")
end

