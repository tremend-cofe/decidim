import { DirectUpload } from "@rails/activestorage";

class DecidimDirectUpload extends DirectUpload {
  // eslint-disable-next-line max-params
  constructor(file, url, delegate, customHeaders = {}) {
    super(file, url, delegate, customHeaders);
  }
}

export class Uploader {
  constructor(modal, options) {
    this.modal = modal;
    this.options = options;
    this.validationSent = false;
    this.errors = []

    if (modal.options.maxFileSize && options.file.size > modal.options.maxFileSize) {
      this.errors = [modal.locales.file_size_too_large]
    } else {
      let url = `${options.url}?${this.getParams(null)}`;
      this.upload = new DecidimDirectUpload(options.file, url, this);
    }
  }

  getParams(blobId) {
    if (blobId) {
      return new URLSearchParams({
        resourceClass: this.modal.options.resourceClass,
        property: this.getProperty(),
        blob: blobId,
        formClass: this.modal.options.formObjectClass
      });
    }
    return new URLSearchParams({
      resourceClass: this.modal.options.resourceClass,
      property: this.getProperty(),
      formClass: this.modal.options.formObjectClass
    });
  }

  validate(blobId) {
    const callback = (data) => {
      let errors = []
      for (const [, value] of Object.entries(data)) {
        errors = errors.concat(value);
      }

      if (errors.length) {
        this.errors = errors;
      }
    }

    if (!this.validationSent) {
      let url = this.modal.input.dataset.uploadValidationsUrl;

      const params = this.getParams(blobId);

      return fetch(`${url}?${params}`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": $("meta[name=csrf-token]").attr("content")
        }
      }).
        then((response) => response.json()).
        then((data) => {
          this.validationSent = true;
          callback(data);
        });
    }

    return Promise.resolve()
  }

  // The following method come from @rails/activestorage
  // {@link https://edgeguides.rubyonrails.org/active_storage_overview.html#direct-upload-javascript-events Active Storage Rails guide}
  directUploadWillStoreFileWithXHR(request) {
    request.upload.addEventListener("progress", ({ loaded, total }) => this.modal.setProgressBar(this.options.attachmentName, Math.floor(loaded / total * 100)));
  }

  getProperty() {
    let property = this.modal.options.addAttribute;
    if (this.modal.options.titled) {
      property = "file"
    }
    return property;
  }

}
