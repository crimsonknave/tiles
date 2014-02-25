module.exports = (arr) ->
  i = arr.length
  if i is 0 then return false

  while --i
    j = Math.floor(Math.random() * (i+1))
    [arr[i], arr[j]] = [arr[j], arr[i]] # use pattern matching to swap

