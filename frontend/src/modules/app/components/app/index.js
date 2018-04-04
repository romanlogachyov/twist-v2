import React from "react";
import { Switch, Route } from "react-router-dom";

import PrivateRoute from "./private_route";
import Books from "modules/app/components/books";
import Book from "modules/app/components/book";
import Chapter from "modules/app/components/book/chapter";
import Login from "modules/app/components/login";

export function App() {
  return (
    <div className="container">
      <Switch>
        <Route path="/login" component={Login} />
        <PrivateRoute exact path="/" component={Books} />
        <PrivateRoute exact path="/books/:permalink" component={Book} />
        <PrivateRoute exact path="/books/:bookPermalink/chapters/:chapterPermalink" component={Chapter} />
        <PrivateRoute component={NotFound} />
      </Switch>
    </div>
  );
}

function NotFound() {
  return (
    <h5 style={{ margin: 40 }}>
      Route not found
    </h5>
  );
}