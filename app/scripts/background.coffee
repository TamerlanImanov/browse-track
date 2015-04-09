'use strict';

chrome.runtime.onInstalled.addListener (details) ->

Stat =
  data: {}
  cur: null

tabChanged = (url) ->
  if Stat.cur
    lst = Stat.data[Stat.cur]
    lst.push(new Date())
  Stat.cur = url
  lst = Stat.data[url] or []
  lst.push(new Date())
  Stat.data[url] = lst
  return Stat.data[url]

calc = (url)->
  lst = Stat.data[url]
  if not lst
    return 0
  n = Math.floor (lst.length / 2)
  res = 0
  for i in [0..n]
    if lst[2 * i + 1] and lst[2 * i]
      res += lst[2 * i + 1].getTime() - lst[2 * i].getTime()
  res += (new Date()).getTime() - lst[lst.length - 1].getTime()
  return res

updateBadge = (url,qwe)->
  if (qwe>0)
    res = parseInt(qwe)
    res +=1
    s = res % 60
    m = Math.floor (res / 60) % 60
    h = Math.floor (res / 3600) % 24
    console.log res + "<- res"
    console.log h + "<- h"
    console.log m + "<- m"
    console.log s + "<- s"
    chrome.browserAction.setBadgeText({text: "#{h}:#{m}:#{s}"})
  else
    res = calc url
    s = Math.floor(res / 1000) % 60
    m = Math.floor(res / 60000) % 60
    h = Math.floor(res / 3600000) % 24
    console.log res + "<- res"
    console.log h + "<- h"
    console.log m + "<- m"
    console.log s + "<- s"
    chrome.browserAction.setBadgeText({text: "#{h}:#{m}:#{s}"})
  
  save url, res
 
extactProtocol = ( url = location.href ) ->
  l = document.createElement "a"
  l.href = url
  return l.protocol

extractDomain = (url) ->
  if (url.indexOf("://") > -1)
    domain = url.split('/')[2]
  else
    domain = url.split('/')[0]
    domain = domain.split(':')[0];
  return domain

chrome.tabs.onActivated.addListener (activeInfo)->
  Stat.curTabId = activeInfo.tabId
  chrome.tabs.get activeInfo.tabId, (tab) ->
    k = extactProtocol tab.url
    console.log "WORK?"
    if (k == "http:" || k == "https:")
      onlyDomain = extractDomain tab.url 
      tabChanged(onlyDomain) if onlyDomain
      updateBadge onlyDomain,localStorage.getItem(onlyDomain)

save = (url,sec) ->
    localStorage.setItem(url,sec)

myTimer = () ->
  if not Stat.curTabId
      return
    chrome.tabs.get Stat.curTabId, (tab)->
      onlyDomain = extractDomain tab.url 
      if onlyDomain
        updateBadge onlyDomain,localStorage.getItem(onlyDomain)

setInterval(myTimer, 1000)