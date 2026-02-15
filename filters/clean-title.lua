local first_h1_removed = false
function Header(el)
    if el.level == 1 and not first_h1_removed then
        first_h1_removed = true
        return {} 
    end
end
