from urllib.parse import urlencode

class UrlListBuilder:
    def __init__(
        self,
        base_url: str = "",
        page_param: str = "page",
        page_start: int = 1,
        page_end: int = 1,
        dataset_id: str = "",
    ):
        self.base_url = base_url
        self.page_param = page_param
        self.page_start = page_start
        self.page_end = page_end
        self.dataset_id = dataset_id

    def build(self) -> dict:
        separator = "&" if "?" in self.base_url else "?"
        urls = []
        for i in range(self.page_start, self.page_end + 1):
            query = urlencode({self.page_param: i})
            urls.append(f"{self.base_url}{separator}{query}")
        return {"urls": urls, "dataset_id": self.dataset_id}
