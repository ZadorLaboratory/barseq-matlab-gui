function restart_app(app)
    % Make current instance of app invisible
    app.UIFigure.Visible = 'off';
    % Open 2nd instance of app
    Test_image();  % <--------------The name of your app
    % Delete old instance
    close(app.UIFigure) %Thanks to Guillaume for suggesting to use close() rather than delete()
end