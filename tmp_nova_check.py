from backend.app.llm.model_factory import get_chat_model


def main() -> None:
    model = get_chat_model()
    response = model.invoke("Reply with exactly: nova_ok")
    print(response)


if __name__ == "__main__":
    main()
