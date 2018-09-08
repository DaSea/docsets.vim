#!/usr/bin/env python
# -*- coding: utf-8 -*-

import vim
import os
import os.path
from leaderf.utils import *
from leaderf.explorer import *
from leaderf.manager import *
from docsetmgr import docsetManager

#*****************************************************
# DocsetsExplorer
#*****************************************************
class DocsetsExplorer(Explorer):
    def __init__(self):
        pass

    def getContent(self, *args, **kwargs):
        """
        Get display content
        """
        if kwargs.get("arguments", {}).get("filetype"):
            ftype = kwargs.get("arguments", {}).get("filetype")[0]
            if docsetManager.hasExistDocsets(ftype):
                return docsetManager.getSearchIndexList(ftype)
            else:
                lfCmd("echohl ErrorMsg | redraw | echon "
                      "'Has no docsets with filetype `%s`| echohl NONE" % ftype)
                return None
        return None

    def getStlCategory(self):
        return "Docsets"

    def getStlCurDir(self):
        return escQuote(lfEncode(os.getcwd()))

#*****************************************************
# DocsetsExplManager
#*****************************************************
class DocsetsExplManager(Manager):
    def __init__(self):
        super(DocsetsExplManager, self).__init__()
        self._match_ids = []
        self._ftype = ''

    def _getExplClass(self):
        return DocsetsExplorer

    def _defineMaps(self):
        lfCmd("call leaderf#docset#Maps()")

    def _acceptSelection(self, *args, **kwargs):
        """
        If select one, how process it?
        """
        if len(args) == 0:
            return
        line = args[0]
        # get path and open it in a window
        path = line.split()[-1]
        #  print(path)
        docsetManager.openSearchResult(self._ftype, path)

    def _getDigest(self, line, mode):
        """
        specify what part in the line to be processed and highlighted
        Args:
            mode: 0, 1, 2, return the whole line
        """
        if not line:
            return ''
        return line[1:]

    def _getDigestStartPos(self, line, mode):
        """
        return the start position of the digest returned by _getDigest()
        Args:
            mode: 0, 1, 2, return 1
        """
        return 1

    def _createHelp(self):
        help = []
        help.append('" <CR>/<double-click>/o : execute command under cursor')
        help.append('" i : switch to input mode')
        help.append('" q : quit')
        help.append('" <F1> : toggle this help')
        help.append('" ---------------------------------------------------------')
        return help

    def _afterEnter(self):
        super(DocsetsExplManager, self)._afterEnter()

    def _beforeExit(self):
        super(DocsetsExplManager, self)._beforeExit()
        for i in self._match_ids:
            lfCmd("silent! call matchdelete(%d)" % i)
        self._match_ids = []

    def startExplorer(self, win_pos, *args, **kwargs):
        if kwargs.get("arguments", {}).get("filetype"): # behavior no change for `LeaderfFile <filetype>`
            self._ftype = kwargs.get("arguments", {}).get("filetype")[0]
            super(DocsetsExplManager, self).startExplorer(win_pos, *args, **kwargs)
            return

        return

#*****************************************************
# docsetsExplManager is a singleton
#*****************************************************
docsetsExplManager = DocsetsExplManager()

__all__ = ['docsetsExplManager']
