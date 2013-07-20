# ポーカーのルールをまとめたモジュール

module PokerLogic

  HAND = 5
  RANKS =  %w( HighCards OnePair TwoPair ThreeOfKind Straight Flush FullHouse FourOfKind StraightFlush RoyalStraightFlush )


  # 勝者を返す
  def match(player, dealer)
    player_rank = eval_hand(player.hand)
    dealer_rank = eval_hand(dealer.hand)

    # 役が違う場合はその時点で判定終了
    case player_rank[:rank] <=> dealer_rank[:rank]
    when 1
      winner = player
    when -1
      winner = dealer
    # 役が同じ場合、判定用の配列を前から比較して、優劣が出た時点で終了
    when 0
      player_rank[:judge].each_index do |i|
        case player_rank[:judge][i] <=> dealer_rank[:judge][i]
        when 0 then next
        when 1
          winner = player
          break
        when -1
          winner = dealer
          break
        end
      end
    end

    winner ||= nil
  end

  def rank_string(hand_cards)
    RANKS[eval_hand(hand_cards)[:rank]]
  end

  private

  def duplicate_num(nums, how_many)
    nums.select {|num| nums.count(num) == how_many}.uniq
  end

  # 役判定
  # 役が同じときのために、判定用の配列も返す
  def eval_hand(hand_cards)
    nums = hand_cards.map {|card| card.number}.sort
    suits = hand_cards.map {|card| card.suit}
    # 手札内の同じ数字の枚数の配列
    nums_pairs = nums.map {|num| nums.count(num)}

    # ペア系の判定
    pair_count = nums_pairs.count(2)
    three_kinds = nums_pairs.include?(3)
    four_kinds = nums_pairs.include?(4)

    # 他の役の判定
    flush = suits.uniq.size == 1
    straight = [nums[-1] - nums[0], pair_count, three_kinds, four_kinds] == [4, 0, false, false]
    royal_straight = nums == [1, 10, 11, 12, 13]

    # 1を最強にする
    nums.map! {|num| num == 1 ? 14 : num}

    if royal_straight and flush
      return {rank: 9}
    elsif straight and flush
      return {rank: 8, judge: [nums[-1]]}
    elsif four_kinds
      return {rank: 7, judge: [duplicate_num(nums, 4)[0]]}
    # フルハウス
    elsif three_kinds and pair_count > 0
      return {rank: 6, judge: [duplicate_num(nums, 3)[0]]}
    elsif flush
      return {rank: 5, judge: [nums[-1]] + nums[0, 4].reverse}
    elsif straight
      return {rank: 4, judge: [nums[-1]]}
    elsif three_kinds
      return {rank: 3, judge: [duplicate_num(nums, 3)[0]]}
    # ツーペア
    elsif pair_count == 4
      return {rank: 2, judge: [duplicate_num(nums, 2).max] + [duplicate_num(nums, 2).min] + [duplicate_num(nums, 1)]}
    # ワンペア
    elsif pair_count == 2
      return {rank: 1, judge: [duplicate_num(nums, 2)[0]] + duplicate_num(nums, 1).reverse}
    # ハイカード(役なし)
    else
      return {rank: 0, judge: [nums[-1]] + nums[0, 4].reverse}
    end
  end
end
