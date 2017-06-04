local Player = require("Player")
local Functions = {}

-----------SHUFFLE DECK----------------NAO FUNCIONA
Functions.shuffle  = function(Player1)
    local deckfim = {}
    local i = 1
    while i < #Player1.deck do
        card = math.random(1,#Player1.deck)
        deckfim.i = Player1.deck.card
        Player1.deck.card = nil
        i = i+1
    end
    Player1.deck = deckfim
    return Player1.deck
end

--------outro shuffle---------FUNCIONA
Functions.shuffle2 = function(a)
	local c = #a
	for i = 1, c do
		local ndx0 = math.random( 1, c )
		a[ ndx0 ], a[ i ] = a[ i ], a[ ndx0 ]
	end
	return a
end
------------COPIAR---------
Functions.copiar = function(card,b)
    for k,v in pairs(card) do
        b[k] = v
    end
    return b
end
-----------FIND-------------
Functions.find = function(a,n)
    local i = 1
    while i <= #a do
        if a[i] == n then
            return i
        else
            i = i+1
        end
    end
end
----------FIND2--------------
Functions.find2 = function(a,n)
    for k,v in pairs(a) do
        if v == n then
        return k
        end
    end
end
------------DRAW----------------
Functions.draw = function(j)
    j.hand[#j.hand+1] = j.deck[#j.deck]
    j.deck[#j.deck] = nil
end

----------GET GOLD-------------
Functions.getgold = function(Player)
    Player.gold = Player.gold+1
end

---------GET STAMINA------------
Functions.getstamina = function(card)
    card.stamina = card.stamina +1
end
--------DISCARD--------------
Functions.discard = function(Player1)
    local h = false
    while h == false do
        print("Discard a card:")
        Functions.printzone(Player1.hand)
        local opcao = tonumber(io.read())
        if opcao ~= nil and opcao <= #Player1.hand and opcao > 0 then
            Player1.graveyard[#Player1.graveyard+1] = Player1.hand[opcao]
            while opcao <= #Player[t].hand do
                Player[t].hand[opcao] = Player[t].hand[opcao+1]
                opcao = opcao+1
            end
            h = true
        else
            print("YOU MUST DISCARD A CARD!")
        end
    end
    if Player1.graveyard[#Player1.graveyard].type ~= "Support" then
        if Player1.graveyard[#Player1.graveyard].effect.ifdiscarded then
            Player1.graveyard[#Player1.graveyard].effect.ifdiscarded(Player1,Player2)
        end
    end
end
------------PRINTZONE----------
Functions.printzone = function(zone)

    local i = 1
    print("#","Name       ","Cost","Type","Power","Loyalty")
    while i <= #zone do
        print(i,zone[i].name,zone[i].cost,zone[i].type,zone[i].power,zone[i].loyalty)
        i = i+1
    end    
end
----------- PRINT CARD---------
Functions.printcard = function(card)
    print("Name: "..card.name)
    print("Cost: "..card.cost)
    print("Type: "..card.type)
    if card.power then
        print("power: "..card.power)
    end
    print("Description: "..card.description)
    if card.loyalty then
        print("Loyalty: "..card.loyalty)
    end
end
-----------DESTROY------------
Functions.destroy = function(card,Destruidor,Player,oponente)
    Player.graveyard[#Player.graveyard+1] = card
    if card.type == "Unit" then
        local j = Functions.find(Player.field,card)
        while j <= #Player.field do
            Player.field[j] = Player.field[j+1]
            j = j+1
        end
    elseif card.type == "Ally" then
        local j = Functions.find(Player.room,card)
        while j <= #Player.room do
            Player.room[j] = Player.room[j+1]
            j = j+1
        end
    end
    print(card.name.." foi destruído.")
    if card.effect then
        if card.effect.ifdies then
            card.effect.ifdies(Player,oponente) --receber o card tbm como primeiro argumento
        else
        end
    end
    if modotchebo and Destruidor then 
        Destruidor.gold = Destruidor.gold+card.cost
        print(Destruidor.name.." recebeu "..card.cost.." de gold!")
    end
end
------------exile----------------------------------------------------------
Functions.exile = function(card,Player,oponente)
    Player.exile[#Player.exile+1] = card
    local j = Functions.find(Player.field,card)
    while j <= #Player.field do
        Player.field[j] = Player.field[j+1]
        j = j+1
    end
    print(card.name.." foi exilado.")
end
-----------combat---------------------------------------------------------
Functions.combat = function(atacante,defensor,Player1,Player2)

    if atacante.power > defensor.power then
        Functions.destroy(defensor,Player1,Player2,Player1)
        if atacante.effect.ifdestroys then
            atacante.effect.ifdestroys(Player1,Player2)
        end
    elseif atacante.power == defensor.power then
        Functions.destroy(defensor,Player1,Player2,Player1)
        Functions.destroy(atacante,Player1,Player1,Player2)
        if atacante.effect.ifdestroys then
            atacante.effect.ifdestroys(Player1,Player2)
        end
        if defensor.effect.ifdestroys then
            defensor.effect.ifdestroys(Player2,Player1)
        end
    elseif atacante.power < defensor.power then
        Functions.destroy(atacante,Player1,Player1,Player2)
        if defensor.effect.ifdestroys then
            defensor.effect.ifdestroys(Player2,Player1)
        end
    end
end

-----------CAST----------------------------------------------------
Functions.cast = function(card,Player1,Player2)
    if card.type == "Support" then
        card.effect(Player1,Player2)
        Player1.graveyard[#Player1.graveyard+1] = card
        Player1.lastsupport = card
    elseif card.type == "Magic" then
        card.effect(Player1,Player2)
        Player1.graveyard[#Player1.graveyard+1] = card
        Player1.magic = Player1.magic-1
    end
end

-----------SUMMON-------------------------------------------------------
Functions.summon = function(card,Player1,Player2)
    if card.type == "Unit" then
        Player1.field[#Player1.field+1] = card
        print(card.name.." was summoned.")
        if card.effect.ifsummoned then
            card.effect.ifsummoned(Player1,Player2)
        end
    end
end
-----------CONVOCAR----------------------------------------------------------
Functions.convocar = function(card,Player1,Player2)
    if card.type == "Ally" then
        Player1.room[#Player1.room+1] = card
        print(card.name.." foi convocado.")
        if card.effect.ifconvocado then
            card.effect.ifconvocado(Player1,Player2)
        end
    end
end

----------PLAY-------------------------------------------------------
Functions.play = function(card,Player1,Player2)
    if card.type == "Unit" then
        Functions.summon(card,Player1,Player2)
    elseif card.type == "Support" or card.type == "Magic" then
        Functions.cast(card,Player1,Player2)
    elseif card.type == "Ally" then
        Functions.convocar(card,Player1,Player2)
    end
end

-----------damage-----------------------------------------------------
Functions.damage = function(alvo,quantidade)
    alvo.life = alvo.life - quantidade
end
-----------GET LIFE----------------------------------------------------
Functions.getlife = function(alvo,quantidade)
    alvo.life = alvo.life + quantidade
end
----------STORM-------------rajada--------------------------------------------
Functions.storm = function(Player1,quantidade)
    Player1.storm = Player1.storm+quantidade
    print(Player1.name.."'s storm was raised by "..quantidade..".")
end
---------ability-------------------------------------------------------
Functions.ability = function(card)
    if card.stamina > 0 then
        card.stamina = card.stamina-1
        card.effect()
    else 
        print("THIS UNIT HAS NO ENERGY LEFT!")
    end
end
-----------end turn------------nao testada
Functions.endturn = function(Player1,Player2)
            print(Player1.name.." turn ends.")
            Player1.storm = 0
            if #Player2.deck > 0 then
                Functions.draw(Player2)
                print(Player2.name.." draws a card.")
            else
                print(Player2.name.."'s deck has no more cards.")
            end
            Functions.getgold(Player2)
            print("Player "..Player2.name.." receives 1 gold.")
            local i = #Player2.field
            while i > 0 do
                Player2.field[i].stamina = 1
                i = i-1
            end
            local h = #Player2.room
            while h > 0 do
                Player2.room[h].stamina = 1
                h = h-1
            end
            Player2.magia = 1
end
------------turn---------------
Functions.turn = function(t)

    while t == 1 or t == 2 do
        
        print("It's player "..Player[t].name.." turn!")
        print("Life: "..Player[t].life,"Gold: "..Player[t].gold,"Magic: "..Player[t].magic,"Storm: "..Player[t].storm)
        print("1 - Hand")
        print("2 - Field")
        print("3 - Room")
        print("4 - Graveyard")
        print("5 - End turn")
        if #Player[t].extra > 0 then
            print("6 - Extra Deck")
        end
        
        local option = tonumber(io.read())
----------SUA MÃO--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
        while option == 1 do
            print("Your hand:")
            print("0 - Return")
            Functions.printzone(Player[t].hand)
            
            local opt = tonumber(io.read())
            
            if opt == nil then
                print("SELECT A VALID OPTION!")
                break
            elseif opt == 0 then
                    break
            elseif opt <= #Player[t].hand and opt > 0 then
                while opt <= #Player[t].hand and opt > 0 do
                    local card = Player[t].hand[opt]
                    Functions.printcard(card)
                    print("0 - Return")
                    print("1 - Play")
                    
                    opcao = tonumber(io.read())
                    
                    if opcao == nil then
                        print("SELECT A VALID OPTION!")
                    
                    elseif opcao == 0 then
                        opt = 0
                        break
                        
                    elseif opcao == 1 and Player[t].gold >= Player[t].hand[opt].cost then
                        Player[t].gold = Player[t].gold - Player[t].hand[opt].cost
                        Functions.play(Player[t].hand[opt],Player[t],Player[y])
                            while opt <= #Player[t].hand do
                                Player[t].hand[opt] = Player[t].hand[opt+1]
                                opt = opt+1
                            end
                            
                    elseif opcao == 1 and Player[t].gold < Player[t].hand[opt].cost then
                        print("YOU DON'T HAVE ENOUGH GOLD! :x")
                    else
                        print("SELECT A VALID OPTION")
                    end
                end
            else
                print("SELECT A VALID OPTION!")
            end
        end
------------------fieldS-------------------
        while option == 2 do
            print("Select field:")
            print("0 - Return")
            print("1 - Your field")
            print("2 - Opponent's field")
                    
            local num = tonumber(io.read())
            
            if num == nil then
                print("THAT IS NOT A VALID OPTION!")
                break
            elseif num == 0 then
                break
            end
                
            while num == 1 do
                print("Your field:")
                print("0 - Return")
                Functions.printzone(Player[t].field)
                local opcao = tonumber(io.read())
                if opcao == nil then
                    print("THAT IS NOT A VALID OPTION!")
                    break
                elseif opcao == 0 then
                    break
                elseif opcao <= #Player[t].field then
                    local card = Player[t].field[opcao]
                    Functions.printcard(card)
                    print("0 - Return")
                    print("1 - Attack")
                    if card.effect.ability then
                        print("2 - Ability")
                    end
                    if card.effect.ability and card.effect.ultra and Player[t].ultra > 0 then
                        print("3 - ULTRA")
                    elseif card.effect.ultra and Player[t].ultra > 0 then
                        print("2 - ULTRA")
                    end
                    local decisao = tonumber(io.read())
                    if decisao == nil then
                        print("THAT IS NOT A VALID OPTION!")
                        break
                    elseif decisao == 0 then
                        break
-----------------------------ATAQUE---------------------------------------------------------------------
                    elseif decisao == 1 then
                        while decisao == 1 do
                            local atacante = card
                            print("Select target:")
                            print("0 - Return")
                            print("1 - Opponent")
                            if #Player[y].field > 0 then
                                print("2 - Enemy units")
                            end
                                    
                            local alvo = tonumber(io.read())
                            
                            if alvo == nil then
                                print("THAT IS NOT A VALID OPTION!")
                                decisao = 0
                                break
                            elseif alvo == 0 then
                                decisao = 0
                                break
                                    
                            elseif alvo == 1 then
                                if atacante.stamina > 0 then
                                    Player[y].life = Player[y].life - atacante.power
                                    print("Player "..Player[y].name.."'s life is now "..Player[y].life..".")
                                    atacante.stamina = atacante.stamina - 1
                                    decisao = 0
                                    break
                                else
                                    print("THIS UNIT HAS NO ENERGY LEFT TO ATTACK! :'(")
                                    decisao = 0
                                    break
                                end
                            end
                                    
                            while alvo == 2 and #Player[y].field > 0 do
                                print("Select target:")
                                print("0 - Return")
                                Functions.printzone(Player[y].field)
                                
                                local num2 = tonumber(io.read())
                                        
                                if num2 == nil then
                                    print("THAT IS NOT A VALID OPTION!")
                                    decisao = 0
                                    break
                                elseif num2 == 0 then
                                    decisao = 0
                                    break
                                        
                                elseif num2 <= #Player[y].field then
                                    local defensor = Player[y].field[num2]
                                    Functions.combat(atacante,defensor,Player[t],Player[y])
                                    decisao = 0
                                    break
                                else
                                    print("THAT IS NOT A VALID OPTION!")
                                    decisao = 0
                                    break
                                end
                            end
                                    
                            if alvo ~= nil and alvo ~= 0 and alvo ~= 1 and alvo ~= 2 then
                                    print("THAT IS NOT A VALID OPTION!")
                                    break
                            end
                            decisao = 0
                        end
-------------------------------ability------------------------------------------------------------------------------------------
                    elseif decisao == 2 and card.effect.ability and card.stamina > 0 then
                        card.effect.ability(Player[t],Player[y])
                        card.stamina = card.stamina-1
                        break
                    elseif decisao == 2 and card.effect.ability and card.stamina < 1 then
                        print("THAT UNIT HAS NO ENERGY LEFT!")
                        break
                    elseif decisao == 2 and Player[t].ultra > 0 and card.effect.ultra and card.stamina > 0 and card.effect.ability == nil then
                        card.effect.ultra(Player[t],Player[y])
                        Player[t].ultra = Player[t].ultra-1
                    elseif decisao == 3 and Player[t].ultra > 0 and card.effect.ultra and card.stamina > 0 then
                        card.effect.ultra(Player[t],Player[y])
                        Player[t].ultra = Player[t].ultra-1
                    else
                        print("THAT IS NOT A VALID OPTION!")
                        break
                    end
                else
                    print("THAT IS NOT A VALID OPTION!")
                    break
                end
            end
                
            while num == 2 do
                print("Opponent's field:")
                print("0 - Return")
                Functions.printzone(Player[y].field)
                local opcao = tonumber(io.read())
                if opcao == nil then
                    print("THAT IS NOT A VALID OPTION!")
                    break
                elseif opcao == 0 then
                    break
                elseif opcao <= #Player[y].field then
                    Functions.printcard(Player[y].field[opcao])
                    print("[Any command] - Return")
                    local option = tonumber(io.read())
                    if option then
                        break
                    end
                end
            end

            if num ~= nil and num ~= 0 and num ~= 1 and num ~= 2 then
                print("THAT IS NOT A VALID OPTION!")
                break
            end
        end
        ------------------room--------------------------------------------
        while option == 3 do
            print("Your room:")
            print("0 - Return")
            Functions.printzone(Player[t].room)
            local opcao = tonumber(io.read())
            if opcao == nil then
                print("THAT IS NOT A VALID OPTION!")
                    break
            elseif opcao == 0 then
                    break
            elseif opcao <= #Player[t].room then
                local card = Player[t].room[opcao]
                Functions.printcard(card)
                print("0 - Return")
                if card.stamina > 0 then
                    print("1 - Ability")
                end
                local decisao = tonumber(io.read())
                if decisao == nil then
                    print("THAT IS NOT A VALID OPTION!")
                    break
                elseif decisao == 0 then
                    break
                elseif decisao == 1 and card.stamina > 0 then
                    card.effect.ability(Player[t],Player[y])
                    card.loyalty = card.loyalty-1
                    card.stamina = card.stamina-1
                    if card.loyalty < 1 then
                        Functions.destroy(card,Player1,Player[t],Player[y])
                    end
                else
                    print("SELECT A VALID OPTION!")
                end
            else
                print("SELECT A VALID OPTION!!")
            end
        end
        
        while option == 4 do
            print("Your graveyard:")
            print("0 - Return")
            Functions.printzone(Player[t].graveyard)
            
            local opti = tonumber(io.read())
            
            if opti == 0 then
                break
            else
                print("You can't do anything for them. :'(")
            end
        end
        
        if option == 5 then
            Functions.endturn(Player[t],Player[y])
            break
        end
        
        while #Player[t].extra > 0 and option == 6 do
            print("Your extra deck:")
            print("0 - Return")
            Functions.printzone(Player[t].extra)
            local option = tonumber(io.read())
            if option ~= nil and option == 0 then
                break
--             elseif option == nil then
--                 break
--             elseif option ~= nil and option > 0 and option <= #Player[t].extra then
--                 local card = Player[t].extra[option]
--                 Functions.printcard(card)
--                 print("0 - Return")
--                 print("1 - Play")
--                 local option = tonumber(io.read())
--                 if option ~= nil and option == 0 then
--                     break
--                 elseif option == nil then
--                     break
--                 elseif option == 1 then
--                     if card.origin then
-- --                         print(card.origin.name)
-- --                         print(Player[t].name)
-- --                         print(card.name)
--                         Functions.destroy(Player[t].field.r,Player[t],Player[t],Player[y])
--                         Functions.summon(card,Player[t],Player[y])
--                         local j = Functions.find(Player[t].extra,card)
--                         while j <= #Player[t].extra do
--                             Player[t].extra[j] = Player[t].extra[j+1]
--                             j = j+1
--                         end
--                         print(card.origin.name.." became "..card.name.."!")
--                     end
--                 else
--                 end
            else
                print("SELECT A VALID OPTION!")
            end
            
        end
            
        if option ~= 1 and option ~= 2 and option ~= 3 and option~= 4 and option ~= 5 and option ~= 6 then
            print("SELECT A VALID OPTION!")
        end
    end
end
------------GAME----------------
Functions.game = function()

    Functions.shuffle2(Player[1].deck)
    Functions.shuffle2(Player[2].deck)
    Functions.draw(Player[1])
    Functions.draw(Player[1])
    Functions.draw(Player[1])
    Functions.draw(Player[1])
    Functions.draw(Player[1])
    Functions.draw(Player[2])
    Functions.draw(Player[2])
    Functions.draw(Player[2])
    Functions.draw(Player[2])
    Functions.draw(Player[2])
    Functions.getgold(Player[1])
    
    while Player[1].life > 0 and Player[2].life > 0 do
        t = 1  y = 2
        Functions.turn(t)
        if Player[1].life <1 then
            print(Player[2].name.." won!")
            break
        elseif Player[2].life <1 then
            print(Player[1].name.." won!")
            break
        end
        t = 2  y = 1
        Functions.turn(t)
        if Player[1].life <1 then
            print(Player[2].name.." won!")
            break
        elseif Player[2].life <1 then
            print(Player[1].name.." won!")
        end
    end
end

return Functions
