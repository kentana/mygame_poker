# ゲームの本体

DEFAULT_SCREEN_W = 1000
DEFAULT_SCREEN_H = 700


require "mygame/boot"
require "./card_deck.rb"
require "./card_player.rb"
require "./poker_logic.rb"


class Poker
  include CardDeck
  include CardPlayer
  extend PokerLogic


  # クラス定数
  # 手札の表示位置
  PLAYER_X = 250
  PLAYER_Y = DEFAULT_SCREEN_H - 100
  DEALER_X = 250
  DEALER_Y = 100
  CARD_MERGIN = 120
  SELECTED_CARD_POP = 50

  # フォント用
  RED = [255, 0, 0]
  GREEN = [0, 255, 0]
  FONT_SIZE = 20

  # メッセージ用
  MESSAGE_X = 10
  MESSAGE_Y = 400
  MATCH_MESSAGE_X = 50
  MATCH_MESSAGE_Y = 500
  RANK_X = 200
  PLAYER_RANK_Y = DEFAULT_SCREEN_H - 220
  DEALER_RANK_Y = 200
  MESSAGE_MERGIN = 30


  def initialize
    @deck = CardDeck::Deck.new
    @player = CardPlayer::Player.new(PokerLogic::HAND, @deck)
    @dealer = CardPlayer::Player.new(PokerLogic::HAND, @deck)

    # 山札表示用の中身の無いカード
    @back_card = CardDeck::Card.back(DEFAULT_SCREEN_W/2, DEFAULT_SCREEN_H/2)

    @win = 0
    @lose = 0
    @result = "win: #{@win}, lose: #{@lose}"

    @match = false
    @winner = nil

    # 手札の表示位置を設定
    hand_rocation(@player.hand, PLAYER_X, PLAYER_Y)
    hand_rocation(@dealer.hand, DEALER_X, DEALER_Y)

    # ディーラーの手札を裏に
    @dealer.turn_cards

    set_bg
  end


  def render
    @bg.render
    @player.hand.each {|card| card.render}
    @dealer.hand.each {|card| card.render}
    @back_card.render
    display_font(@result, MESSAGE_X, MESSAGE_Y-MESSAGE_MERGIN*3)

    if @match
      display_rank
      display_font("Push Enter for next game", MESSAGE_X, MESSAGE_Y, GREEN)
      display_match_message
    else
      display_font("Click cards you want to discard", MESSAGE_X, MESSAGE_Y, GREEN)
      display_font("Push Enter to discard and have a match", MESSAGE_X, MESSAGE_Y+MESSAGE_MERGIN, GREEN)
    end
  end

  private

  # 山札と手札をリセット
  def reset
    @deck.reset
    @player.make_hand
    @dealer.make_hand

    hand_rocation(@player.hand, PLAYER_X, PLAYER_Y)
    hand_rocation(@dealer.hand, DEALER_X, DEALER_Y)

    @dealer.turn_cards
    @match = false
  end

  # 背景画像をセット
  def set_bg
    @bg = Image.new("images/bg.png")
    @bg.x = 0
    @bg.y = 0
  end

  # 文字の表示の基本設定
  def display_font(content, x, y, color=nil, size=FONT_SIZE)
    fnt = Font.new(content)
    fnt.x = x
    fnt.y = y
    fnt.ttf_path = "fonts/SourceCodePro-Regular.ttf"
    fnt.size = size
    fnt.color = color if color
    fnt.render
  end

  # 役の名前を表示
  def display_rank
    player_rank = Poker.rank_string(@player.hand)
    dealer_rank = Poker.rank_string(@dealer.hand)

    display_font(player_rank, RANK_X, PLAYER_RANK_Y, RED)
    display_font(dealer_rank, RANK_X, DEALER_RANK_Y, RED)
  end

  # 勝敗の結果を表示
  def display_match_message
    if @winner == @player
      display_font("You win!!", MATCH_MESSAGE_X, MATCH_MESSAGE_Y, [255, 153, 0])
    else
      display_font("You lose...", MATCH_MESSAGE_X, MATCH_MESSAGE_Y, [102, 102, 255])
    end
  end

  # 手札の表示位置の設定
  def hand_rocation(hand, start_x, start_y)
    hand.each_index do |index|
      hand[index].x = index * CARD_MERGIN + start_x
      hand[index].y = start_y
    end
  end

  # カードをクリックされた時の処理
  def click_event(event)
    @player.hand.each do |card|
      card.click if card.clicked?(event)

      card.y -= SELECTED_CARD_POP if card.clicked and card.y == PLAYER_Y
      card.y += SELECTED_CARD_POP unless card.clicked or card.y == PLAYER_Y
    end
  end

  # 手札を交換
  def exchange_hand(player = @player)
    discard_num = player.hand.map {|card| card.clicked}.count(true)
    player.discard
    discard_num.times { player.draw }

    x = player == @player ? PLAYER_X : DEALER_X
    y = player == @player ? PLAYER_Y : DEALER_Y

    hand_rocation(player.hand, x, y)
  end

  # ディーラーの手札交換
  def dealer_change
    rank = Poker.rank_string(@dealer.hand)
    nums = @dealer.hand.map {|card| card.number}

    case rank
    when "HighCards"
      @dealer.hand.each {|card| card.click}
    when "OnePair", "TwoPair", "ThreeOfKind"
      @dealer.hand.each {|card| card.click if nums.count(card.number) == 1}
    end

    exchange_hand(@dealer)
    @dealer.hand.each {|card| card.turn if card.face == false}
  end


  # 勝負後の処理
  def match
    @winner = Poker.match(@player, @dealer)

    if @winner == @player
      @win += 1
    else
      @lose += 1
    end

    @result = "win: #{@win} lose: #{@lose}"
    @match = true
  end
end



poker = Poker.new

# イベント処理
match_flag = true

# クリックの処理
MyGame.add_event(:mouse_button_down) do |event|
  poker.send(:click_event, event)
end

# Enterの挙動
MyGame.add_event(:key_down) do |event|
  if event.sym == MyGame::Key::RETURN
    # 勝負後
    if match_flag
      poker.send(:exchange_hand)
      poker.send(:dealer_change)
      poker.send(:match)
      match_flag = false
    # 捨てるカードを選ぶとき
    else
      poker.send(:reset)
      match_flag = true
    end
  end

  # ESCで終了
  exit(0) if event.sym == MyGame::Key::ESCAPE
end


# メインループ
main_loop do
  poker.render
end
