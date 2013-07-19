# トランプゲームのプレイヤー

module CardPlayer
  class Player
    def initialize(hand_num, deck)
      @hand_num = hand_num
      @deck = deck
      make_hand
    end

    def make_hand
      @hand = Array.new(@hand_num) { @deck.deal }
      @hand.sort_by! {|card| card.number}
    end

    # 手札を全てめくる
    def turn_cards
      @hand.each {|card| card.turn}
    end

    # カードを引いて、ソート
    def draw
      @hand << @deck.draw
      @hand.sort_by! {|card| card.number}
    end

    def discard
      @hand.delete_if {|card| card.clicked}
    end

    attr_reader :hand
  end
end
