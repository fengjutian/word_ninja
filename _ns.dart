      ),) 
      Expanded(child: Row(children: [ 
        NavigationRail( 
          selectedIndex: _calcIndex(context),  
          onDestinationSelected: (i) => _navigate(context, i),  
          labelType: NavigationRailLabelType.all,  
          leading: const Padding(  
            padding: EdgeInsets.symmetric(vertical: 8),  
            child: Text(chr(240)+chr(159)+chr(144)+chr(162), style: TextStyle(fontSize: 24)), 
