var DemoComponent = React.createClass({displayName: 'Demo Component',
	handleClick: function(){
		alert(123);
	},
  render: function() {
    return <div className={this.props.name} onClick={this.handleClick}>Hello {this.props.user_name}!</div>;
  }
});

