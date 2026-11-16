-- Filtre pandoc pour l'EPUB :
--  * retire le sommaire paginé (inutile sur liseuse : la table des matières est générée)
--  * transforme les styles Word (custom-style) en classes CSS
--  * supprime les blocs réservés à Word (openxml)
local retirer = { Sommaire = true, TitreSommaire = true }

function Div(el)
  local style = el.attributes["custom-style"]
  if style then
    if retirer[style] then return {} end
    el.attributes["custom-style"] = nil
    el.classes:insert(style:lower())
  end
  return el
end

function RawBlock(el)
  if el.format == "openxml" then return {} end
end
