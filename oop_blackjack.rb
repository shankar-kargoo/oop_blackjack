# 'object oriented blackjack'
require 'rubygems'
require 'pry'

class Card
  
  attr_accessor :suite, :face_value

  def initialize (s, v)
    @suite = s
    @face_value = v
  end

  def pretty_output
   "The #{face_value} of #{find_suite}"
  end

  def find_suite
    case suite
      when 'H' then 'Hearts'
      when 'S' then 'Spades'
      when 'D' then 'Diamonds'
      when 'C' then 'Clubs'
    end
  end

  def to_s
    pretty_output
  end
    
end

class Deck

	attr_accessor :cards
	
	def initialize
		@cards = []
		suites = ['H', 'S', 'D', 'C']
		numbers = [ '2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A']
			suites.each do |s|
				numbers.each do |n|
					@cards << Card.new(s, n)					
				end
			end
    cards.shuffle!
	end
	
	def shuffle!
		@cards.shuffle!
	end

	def deal_card
		cards.pop
	end

  def size
    cards.size
  end

end

module Hand
  def show_hand
    puts "----------#{name}'s hand is-----------"
    cards.each do |card|
      puts "=> #{card}"  
    end
    puts "=> Total: #{total}"
  end
  
  def total
    face_values = cards.map{|card| card.face_value }
    sum = 0
    face_values.each do |val|
        if val == 'A'
          sum += 11
        elsif val.to_i == 0
          sum += 10 
        else
          sum += val.to_i    
        end
    end
    #correction for A
     face_values.select{|val| val == 'A' }.count.times do
      break if sum <= Blackjack::BLACKJACK_AMOUNT
        sum -=10 
     end
    sum
  end

  def add_card(new_card)
    cards << new_card
  end

  def is_busted?
    total > Blackjack::BLACKJACK_AMOUNT
  end
end

class Player
  include Hand
  attr_accessor :name, :cards
  
  def initialize(n)
    @name = n
    @cards = []
  end

end

class Dealer
  include Hand
  attr_accessor :name, :cards
  
  def initialize
    @name = "Dealer"
    @cards = []
  end
  
  def show_flop
    puts "=> Dealer's first card is hidden"
    puts "=> Dealer's second card is #{cards[1]}"
  end


end

class Blackjack

  attr_accessor :deck, :player, :dealer
  BLACKJACK_AMOUNT = 21
  DEALER_HIT_MIN = 17

  def initialize
    @deck = Deck.new
    @player = Player.new("Player1")
    @dealer = Dealer.new
  end

  def set_player_name
    puts "what is your name?"
    player.name = gets.chomp
  end

  def deal_cards
    player.add_card(deck.deal_card)
    dealer.add_card(deck.deal_card)
    player.add_card(deck.deal_card)
    dealer.add_card(deck.deal_card)
  end

  def show_hand
    player.show_hand
    dealer.show_flop
  end

  def blackjack_or_bust?(player_or_dealer)
    if player_or_dealer.total == BLACKJACK_AMOUNT
      if player_or_dealer.is_a?(Dealer)
        puts "Sorry, dealer hit blackjack. #{player.name} loses"
      else
        puts "Congratulations, you hit blackjack! #{player.name} won!"
      end
      play_again?
      exit      
    elsif player_or_dealer.is_busted?
      if player_or_dealer.is_a?(Dealer)
        puts "Dealer went bust, #{player.name} wins!"
      else
        puts "Sorry, #{player.name} busted, #{player.name} loses."
      end
      play_again?
      exit
    end
  end

  def player_turn
    puts "#{player.name}'s turn."
    
    blackjack_or_bust?(player)

    while !player.is_busted?
      puts "What would you like to do? hit 1) to hit and 2) to stay"
      response = gets.chomp
      
      if !['1', '2'].include?(response)
        puts "Error: you must enter 1 or 2"
        next
      end

      if response == '2'
        puts "=> #{player.name} stays at #{player.total}"
        break
      end

      #hit
      new_card = deck.deal_card
      puts "=> Dealing card to #{player.name} : #{new_card}"
      player.add_card(new_card)
      puts "=> #{player.name}'s total is now: #{player.total}"
      blackjack_or_bust?(player)
    end
  end

  def dealer_turn
    puts "Dealer's turn"
    blackjack_or_bust?(dealer)
    while dealer.total < DEALER_HIT_MIN 
      new_card = deck.deal_card
      dealer.add_card(new_card)
      puts "=> Dealing card to dealer: #{new_card}"      
      puts "=> Dealer's total is now: #{dealer.total}"
      blackjack_or_bust?(dealer)   
    end
    puts "Dealer Stays at #{dealer.total}"
  end

  def who_won?(player, dealer)
    if dealer.total == player.total
      puts "Its a tie, no one wins"
    elsif dealer.total > player.total
      puts "Sorry, dealer wins, dealer has a better hand"
    else
      puts "Congratulations, you win, you have a better hand"
    end
    play_again?
    exit
  end

  def play_again?
    puts "Would you like to play again. Enter Y or N"
    response = gets.chomp
    if response != 'Y'
        puts "It was fun playing with you #{player.name}. Do come back when you have some time"
        exit
    else 
      puts "starting new game....."
      puts ""
      deck = Deck.new
      player.cards = []
      dealer.cards = []
      start
    end
  end

  def start
    set_player_name
    deal_cards
    show_hand
    player_turn
    dealer_turn
    who_won?(player, dealer)
    play_again?
  end
end

game = Blackjack.new
game.start

