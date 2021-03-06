import * as React from "react"

import QueryWrapper from "../../../QueryWrapper"
import commentsQuery from "./CommentsQuery"
import CommentForm from "./CommentForm"
import Comment, { CommentProps } from "./Comment"

type CommentsProps = {
  noteId: string,
  comments: CommentProps[]
}

type CommentsState = {
  comments: CommentProps[]
}

class Comments extends React.Component<CommentsProps, CommentsState> {
  state = { comments: this.props.comments }

  renderComments() {
    return this.state.comments.map((comment) => <Comment {...comment} key={comment.id}  />)
  }

  updateComments = (comments: CommentProps[]) => {
    this.setState({comments: comments})
  }

  render() {
    return (
      <div>
        {this.renderComments()}
        <CommentForm noteId={this.props.noteId} updateComments={this.updateComments} />
      </div>
    )
  }
}

type WrappedCommentsProps = {
  noteId: string,
}

export default class WrappedComments extends React.Component<WrappedCommentsProps> {
  render() {
    const {noteId} = this.props
    return (
      <QueryWrapper query={commentsQuery} variables={{noteId}}>
        {({comments}) => <Comments noteId={noteId} comments={comments} /> }
      </QueryWrapper>
    )
  }
}
