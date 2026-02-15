local first_h1_removed = false

function Header(el)
    if el.level == 1 and not first_h1_removed then
        first_h1_removed = true
        return {}
    end
end

function Link(el)
    local url = el.target
    local video_id = url:match('v=([%w%-_]+)') or url:match('youtu%.be/([%w%-_]+)')
    
    if video_id then
        -- CONSTRUCCIÓN PASO A PASO PARA EVITAR ERRORES
        local base = "https://www.youtube.com"
        local full_url = base .. video_id
        
        local html = '<div class="responsive-embed widescreen">' ..
                     '<iframe width="560" height="315" src="' .. full_url .. 
                     '" frameborder="0" allowfullscreen></iframe>' ..
                     '</div>'
        return pandoc.RawInline('html', html)
    end
end
