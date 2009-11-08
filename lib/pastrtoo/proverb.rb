module PastrToo
  class Proverb
    BASES = <<BASES.split("\n")
A bird in the hand
A friend in need
A job worth doing
A little knowledge
A stolen pleasure
A thing of beauty
A woman's wrath
A change
A house divided against itself
A journey of a thousand miles
A penny saved
A place for everything
A new broom
A prophet
A problem shared
A stitch in time
A watched pot
A woman's work
A man's work
A woman's place
A rolling stone
Absolute power
All work and no play
All good things
All the world
Actions
An Englishman's home
Anger
Beggars
Blind ambition
Charity
Cleanliness
Crime
Curiosity
Envy
Early to bed and early to rise
Guests and fish
Evil
Generosity
Greatness
God in his wisdom
Haste
Heaven above
Hindsight
Honesty
Impulsive behavior
Jealousy
Love
Misery
Money
Much ado about nothing
One good turn
Pride
Procrastination
Regret
Revenge
Selfishness
Success
The darkest hour
The devil you know
The early bird
The pursuit of happiness
The road less travelled
The road to hell
BASES

    ENDINGS = <<ENDINGS.split("\n")
smells after three days.
never won a fair lady.
breeds contempt.
brings happiness.
can work miracles.
cannot buy happiness.
comes before a fall.
comes to those who wait.
corrupts absolutely.
costs nothing.
does nobody any good.
doesn't pay.
first
has a silver lining.
heals all wounds.
sucks.
hurts.
is a dangerous thing.
is a joy forever.
is a mixed blessing.
is bad news.
is best forgotten.
is better than nothing.
is bliss.
is cheap.
is good news.
is its own reward.
is next to godliness.
is only skin deep.
is often spoken in jest.
is sweet.
is the best medicine.
is the best policy.
is the root of all evil.
is the path to wisdom.
is a thing of beauty.
doesn't grow on trees
justifies the means.
abhors a vaccuum.
kills.
lasts forever.
leads to a lifetime of regret.
makes you stronger.
pleases no one.
helps those who help themselves.
speaks louder than words.
will move mountains.
ENDINGS
    def self.sample(search = nil)
      if search and base = BASES.select{|ba| ba.match(/#{search.to_s.chomp}/i) }.sort_by { |a| rand(100) }.first
        "%s %s" % [base, ENDINGS.sort_by { |a| rand(100)}.first]
      else
        "%s %s" % [BASES.sort_by { |b| rand(100) }.first, ENDINGS.sort_by { |a| rand(100)}.first]
      end
    end
  end
end
